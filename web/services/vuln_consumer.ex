defmodule Service.VulnConsumer do
  use GenServer
  import Ecto.Query, only: [from: 2]
  require Logger
  alias Models.PackageMonitor
  alias Models.Package
  alias Models.Monitor
  alias Models.Alert
  alias Models.User
  alias Models.Vuln
  alias Models.VulnEffect


  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(initial_state) do
    Process.register(self, :vuln_consumer)
    {:ok, initial_state}
  end

  defp get_req_version(matchspec) when is_tuple(matchspec) do
    case is_version_req?(matchspec) do
      true -> 
        {:const, spec} = matchspec
        spec
      _ -> Tuple.to_list(matchspec) |> get_req_version
    end
  end

  defp get_req_version(matchspec) when is_list(matchspec) do
    Enum.map(matchspec, fn term -> get_req_version(term) end)
      |> List.flatten
      |> Enum.filter(fn term -> term != :empty end)
      |> Enum.map(fn version -> drop_pre(version) end)
      |> Enum.uniq
  end


  def matches?(package_version, effect_version) do
    {:ok, req} = VPVersion.parse_requirement(effect_version)
    case VPVersion.parse(package_version) do
      {:ok, version} -> VPVersion.match?(version, req)
      :error -> :error
    end

  end




  def is_vulnerable?(package, effects) do
    {unsafe, safe} = Enum.partition(effects, 
      fn effect -> effect.vulnerable end) 
    #match a vuln
    matches_unsafe = (unsafe
        |> Enum.any?(fn effect -> 
            matches?(package.version, effect.version)
          end))

    matches_safe = (safe
        |> Enum.any?(fn effect ->
            matches?(package.version, effect.version)
          end))

    res = matches_unsafe or (not matches_safe and length(safe) > 0)
    len = length(safe)
    matches_unsafe or ((not matches_safe) and length(safe) > 0)
    #match a patched ^^
  end


  def alert_exists?(monitor_id, package_id, vuln_id) do
      (from a in Alert, 
        where: 
          a.monitor_id == ^monitor_id and 
          a.package_id == ^package_id and
          a.vuln_id == ^vuln_id, 
        select: a) |> Repo.all != []
  end


  def create_monitor_alert(monitor_id, package_id, vuln) do
    case alert_exists?(monitor_id, package_id, vuln.id) do
      true -> 
        Logger.debug("alert already exists")
        :exists
      false -> 
        alert = Alert.allocate(%{
          :monitor_id => monitor_id, 
          :vuln_id => vuln.id, 
          :package_id => package_id}
        ) |> Repo.insert
        Logger.debug("Created alert for #{monitor_id} and package #{package_id} and vuln #{vuln.id}")
        {alert, vuln}
    end
  end


  def email_alert(alert, vuln) do
    package = Repo.get(Package, alert.package_id)
    monitor = Repo.get(Monitor, alert.monitor_id)
    user = Repo.get(User, monitor.user_id)
    GenServer.cast(:emailer, {:alert, alert, vuln, package, monitor, user})
  end


  defp create_alert(package, vuln) do
    monitors = (from pm in PackageMonitor, 
      where: pm.package_id == ^package.id, 
      select: pm)
      |> Repo.all
      |> Enum.map(&(create_monitor_alert &1.monitor_id, &1.package_id, vuln))
      |> Enum.filter(fn alert -> alert != :exists end)
      |> Enum.map(fn {alert, vuln} -> email_alert(alert, vuln) end)

  end


  def handle_cast({:new_vuln, vuln}, state) do
    vuln.effects
      |> Enum.map(fn effect -> 
           (from p in Package, where: ilike(p.name, ^effect.name), select: p) 
           |> Repo.all 
        end)
      |> List.flatten
      |> Enum.filter(fn package -> is_vulnerable?(package, vuln.effects) end)
      |> Enum.map(&(create_alert(&1, vuln)))
    {:noreply, state}
  end




end