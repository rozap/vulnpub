

defmodule Manifest.Parser.NPM do
  # require Manifest.Parser.Parser
  # use Manifest.Parser.Parser
  import Manifest.Parser.Parser

  @latest ["l", "a", "t", "e", "s", "t"]


  defp to_spec(@latest), do: "*.*.*"

  defp to_spec(["~" | rest]) do
    "3.3.3"
  end

  defp to_spec(["^" | rest]) do
    "3.3.3"
  end


  ##convert the node versions from eg: 
  #~1.2.3 --> 1.2.*
  #^1.2.3 --> 1.*.*
  defp convert_versions(deps) do
    Enum.map(deps, fn {name, version} -> 
      version = String.split(version, "", trim: true) |> to_spec
      {name, version}
    end)
  end
  
  def parse_deps(jsobj, monitor) do
    convert_versions(jsobj["dependencies"])
      |> create_packages(monitor)
  end

  def parse(filename, details, monitor) do
    get_package_listing(filename, details, monitor)
      |> Jazz.decode!    
      |> parse_deps(monitor)
  end
end