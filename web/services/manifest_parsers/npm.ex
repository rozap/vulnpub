

defmodule Manifest.Parser.NPM do
  # require Manifest.Parser.Parser
  # use Manifest.Parser.Parser
  import Manifest.Parser.Parser


  ##convert the node versions from eg: 
  #~1.2.3 --> 1.2.*
  #^1.2.3 --> 1.*.*
  defp convert_versions(deps) do
    Enum.map(deps, fn {name, raw_version} -> 
      version = String.split(raw_version, "", trim: true) |> to_spec
      {name, version, raw_version}
    end)
  end
  
  def parse_deps(jsobj, monitor) do
    convert_versions(jsobj["dependencies"])
  end

  def parse(filename, details, monitor) do
    get_package_listing(filename, details, monitor)
      |> Jazz.decode!    
      |> parse_deps(monitor)
      |> create_packages(monitor)
  end
end