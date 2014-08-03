defmodule Service.MonitorConsumer do
  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(initial_state) do
    Process.register(self, :monitor_consumer)
    {:ok, initial_state}
  end


  require Manifest.Parser.NPM
  def get_parser(:npm), do: Manifest.Parser.NPM
  def get_parser(:pypi), do: Manifest.Parser.PyPi
  def get_parser(:dpkg), do: Manifest.Parser.Dpkg

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
    Dict.to_list(jsobj)
      |> Enum.map(fn {kind, details} -> {String.to_atom(kind), Dict.to_list(details)} end)
      |> Enum.map(fn {kind, node} -> parse(kind, node, monitor) end)
  end

  def handle_cast({:create, monitor}, state) do
    HTTPotion.start
    response = HTTPotion.get monitor.manifest
    if HTTPotion.Response.success? response do
      case  JSON.decode response.body do
        {:ok, jsobj} -> parse_manifest jsobj, monitor
        _ -> :io.format("malformed json")
      end
    else
      :io.format("manifest failed, not accessible~n")
    end
    {:noreply, state}
  end
end