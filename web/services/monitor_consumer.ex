defmodule Service.MonitorConsumer do
  use GenServer
  require Util
  alias Models.Monitor
  alias Models.PackageMonitor
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
    GenServer.cast(:logger, {
      :warn, [message: "Unknown manifest node named: ", name: nodename]
    })
  end


  defp update_monitor_timestamp(monitor) do
    monitor = Repo.get Monitor, monitor.id
    monitor = %{monitor | last_polled: Util.now}
    Repo.update(monitor)
    GenServer.cast(:logger, {:debug, [msg: "Updated monitor", monitor: monitor.id]})
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

  def handle_cast({:create, monitor}, state) do
    try do
      HTTPotion.start
      GenServer.cast(:logger, {:info, [message: "Getting url: ", url: monitor.manifest]})
      response = HTTPotion.get monitor.manifest
      if HTTPotion.Response.success? response do
        Jazz.decode!(response.body)
          |> parse_manifest(monitor)
          |> update_monitor_timestamp
      else
        GenServer.cast(:logger, 
          {
            :warn, 
            [message: "manifest not accessible", location: monitor.manifest]
          }
        )
      end
    rescue
      e -> GenServer.cast(:logger, {:error, [e: e]})
    end

    {:noreply, state}
  end
end