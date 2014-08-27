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
  def get_parser(:manual), do: Manifest.Parser.Manual

  defp allocate(package_name, version, homepage, monitor) do
    Models.Package.allocate(%{
      :name => package_name,
      :version => version, 
      :monitor_id => monitor.id
    }) 
  end

  defp parse(:packages, node, monitor) do


    Enum.map(node, fn {package_name, details} -> allocate(package_name, details["version"], "home", monitor) end)

  end


  defp fetch_managed(filename, details, monitor) do
    parser = get_parser String.to_atom(details["manager"])
    parser.parse(filename, details, monitor)
  end

  defp parse(:managed, node, monitor) do
    Enum.map(node, fn {filename, details} -> fetch_managed(filename, details, monitor) end)
  end


  defp parse_manifest jsobj, monitor do
    Map.to_list(jsobj)
      |> Enum.map(fn {kind, details} -> {String.to_atom(kind), Map.to_list(details)} end)
      |> Enum.map(fn {kind, node} -> parse(kind, node, monitor) end)
  end

  def handle_cast({:create, monitor}, state) do
    HTTPotion.start
    response = HTTPotion.get monitor.manifest
    if HTTPotion.Response.success? response do
      Jazz.decode!(response.body)
        |> parse_manifest(monitor)
    else
      :io.format("manifest failed, not accessible~n")
    end
    {:noreply, state}
  end
end