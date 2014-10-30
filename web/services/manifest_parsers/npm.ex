

defmodule Manifest.Parser.NPM do
  # require Manifest.Parser.Parser
  # use Manifest.Parser.Parser
  import Manifest.Parser.Parser

  @latest ["l", "a", "t", "e", "s", "t"]
  @any "*"

  defp to_spec(@any), do: "*.*.*"
  defp to_spec(@latest), do: to_spec(@any)

  defp to_spec(["~" | rest]) do
    Enum.join(rest, "") 
      |> Version.parse
      |> (fn {:ok, version} -> "#{version.major}.#{version.minor}.*" end).()
  end

  defp to_spec(["^" | rest]) do
    Enum.join(rest, "") 
      |> Version.parse
      |> (fn {:ok, version} -> "#{version.major}.*.*" end).()
  end

  defp to_spec(version), do: Enum.join(version, "")


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
      |> create_packages(monitor)
  end

  def parse(filename, details, monitor) do
    get_package_listing(filename, details, monitor)
      |> Jazz.decode!    
      |> parse_deps(monitor)
  end
end