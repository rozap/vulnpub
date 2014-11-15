defmodule Service.MonitorConsumer do
  use GenServer
  require Util
  require Logger
  alias Models.Monitor
  alias Models.PackageMonitor
  alias Models.Package
  alias Models.Vuln
  alias Models.VulnEffect
  alias Service.VulnConsumer

  import Ecto.Query, only: [from: 2]

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(initial_state) do
    Process.register(self, :monitor_consumer)
    {:ok, initial_state}
  end

  def get_parser(:npm), do: Manifest.Parser.NPM
  def get_parser(:pypi), do: Manifest.Parser.PyPi
  def get_parser(:dpkg), do: Manifest.Parser.Dpkg
  def get_parser(:rubygems), do: Manifest.Parser.RubyGems
  def get_parser(:unmanaged), do: Manifest.Parser.Unmanaged


  defp fetch_managed(filename, details, monitor) do
    parser = get_parser String.to_atom(details["manager"])
    parser.parse(filename, details, monitor)
  end

  defp parse(:managed, node, monitor) do
    Map.to_list(node)
      |> Enum.map(fn {filename, details} -> 
        fetch_managed(filename, details, monitor) 
      end)
  end

  defp parse(:unmanaged, node, monitor) do
    get_parser(:unmanaged).parse(node, monitor)
  end

  defp parse(nodename, _, _) do
    Logger.warn "Unknown manifest node named: #{nodename}"
  end


  defp update_monitor_status(monitor, status) do
    monitor = Repo.get Monitor, monitor.id
    monitor = %{monitor | last_polled: Util.now, status: status}
    Repo.update(monitor)
    Logger.info "Updated monitor #{monitor.id} status: #{status}"
    monitor
  end


  defp parse_manifest(jsobj, monitor) do
    package_monitors = Map.to_list(jsobj)
      |> Enum.map(fn {kind, details} -> {String.to_atom(kind), details} end)
      |> Enum.map(fn {kind, node} -> parse(kind, node, monitor) end)
      |> List.flatten

    {:ok, _} = Repo.transaction(fn -> 
      
      (from pm in PackageMonitor, where: pm.monitor_id == ^monitor.id) 
        |> Repo.delete_all

      Enum.map(package_monitors, fn pm -> Repo.insert(pm) end)
    
    end)
    
    monitor
  end


  ##
  # Takes a dict of vuln_id => {vuln_effect, vuln} and the monitor's packages
  # gives back all a list of {vuln, vulnerable_packages} tuples
  defp find_vulnerable(vulns, packages) do
      Enum.map(vulns, fn {vuln_id, vuln_effect_pairs} -> 
        effects = Enum.map(vuln_effect_pairs, fn {effect, vuln} -> effect end)

        vulnerable_packages = Enum.filter(packages, fn package -> 
          name_matches = Enum.any?(effects, fn effect -> 
            String.downcase(effect.name)
              |> String.contains?(String.downcase(package.name))
          end)
          name_matches and VulnConsumer.is_vulnerable?(package, effects)
        end)

        {_, vuln} = hd(vuln_effect_pairs)
        IO.puts "VULN ID #{vuln_id}"
        {vuln, vulnerable_packages}
        IO.puts "VULN EFFECT PAIRS \n #{inspect vuln}"
        {vuln, vulnerable_packages}
    end)
    |> Enum.filter(fn {_, vulnerable_packages} -> length(vulnerable_packages) > 0 end)
  end



  defp create_alerts(vulns, monitor) do
    Enum.map(vulns, fn {vuln, vulnerable_packages} -> 
      Enum.map(vulnerable_packages, fn package -> 
        VulnConsumer.create_monitor_alert(monitor.id, package.id, vuln)
      end)
      |> Enum.filter(fn alert -> alert != :exists end)
    end)
    |> List.flatten
  end


  ##
  # packages = this monitor's packages
  # for each vuln effect (joined to vuln)
  #   filter out ok packages
  #   create alerts
  defp check_old_vulns(monitor) do 
    packages = (from pm in PackageMonitor, 
      inner_join: p in Package, on: pm.package_id == p.id,
      select: p) |> Repo.all

    (from ve in VulnEffect, 
      inner_join: v in Vuln, on: ve.vuln_id == v.id,
      select: {ve, v})
      |> Repo.all
      |> Enum.group_by(fn {_, vuln} -> vuln.id end)
      |> find_vulnerable(packages)
      |> create_alerts(monitor)
  end

  def handle_cast({:create, monitor}, state) do
    HTTPotion.start
    try do
      Logger.info "Getting url #{monitor.manifest}"
      response = HTTPotion.get monitor.manifest
      if HTTPotion.Response.success? response do
        Jazz.decode!(response.body)
          |> parse_manifest(monitor)
          |> update_monitor_status("OK")
          |> check_old_vulns
      else
        update_monitor_status(monitor, "Manifest not accessible!")
        Logger.warn("Manifest not accessible: #{monitor.manifest}")
      end
    rescue
      HTTPotion.HTTPError -> 
        status = "HTTPError: #{monitor.manifest} not accessible!"
        update_monitor_status(monitor, status)        
        Logger.warn(status)
      Jazz.SyntaxError -> 
        status = "JSON Error: #{monitor.manifest} does not contain valid JSON."
        update_monitor_status(monitor, status)        
        Logger.warn(status)
      e -> 
        update_monitor_status(monitor, "Unknown error processing the manifest!")
        opts = struct(Inspect.Opts, [])
        Inspect.Algebra.format(Inspect.Algebra.to_doc(e, opts), 80) |> Logger.error
    end
    {:noreply, state}
  end
end