defmodule Service.MonitorConsumer do
  use GenServer

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
      |> Enum.map(fn {filename, details} -> fetch_managed(filename, details, monitor) end)
  end

  defp parse(:unmanaged, node, monitor) do
    get_parser(:unmanaged).parse(node, monitor)
  end

  defp parse(nodename, _, _) do
    GenServer.cast(:logger, {:warn, [message: "Unknown manifest node named: ", name: nodename]})
  end


  defp parse_manifest(jsobj, monitor) do
    Map.to_list(jsobj)
      |> Enum.map(fn {kind, details} -> {String.to_atom(kind), details} end)
      |> Enum.map(fn {kind, node} -> parse(kind, node, monitor) end)
  end

  def handle_cast({:create, monitor}, state) do
    HTTPotion.start
    try do
      GenServer.cast(:logger, {:info, [message: "Getting url: ", url: monitor.manifest]})
      response = HTTPotion.get monitor.manifest
      if HTTPotion.Response.success? response do
        Jazz.decode!(response.body)
          |> parse_manifest(monitor)
      else
        GenServer.cast(:logger, {:warn, [message: "manifest not accessible", location: monitor.manifest]})
      end
    rescue
      e -> GenServer.cast(:logger, {:error, [error: e]})
    end


    {:noreply, state}
  end
end