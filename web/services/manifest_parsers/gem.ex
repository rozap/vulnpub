

defmodule Manifest.Parser.Gem do
  # require Manifest.Parser.Parser
  # use Manifest.Parser.Parser
  import Manifest.Parser.Parser


  def replace_minor(version) do
    String.split(version, ".")
      |> List.replace_at(2, "x")
      |> Enum.join(".")
      |> String.strip(?~)
  end

  def replace_major(version) do
    String.split(version, ".")
      |> List.replace_at(2, "x")
      |> List.replace_at(1, "x")
      |> Enum.join(".")
      |> String.strip(?^)
  end


  ##convert the node versions from eg: 
  #~1.2.3 --> 1.2.x
  #^1.2.3 --> 1.x.x
  defp convert_versions(deps) do
    (Enum.filter(deps, fn {name, version} -> String.at(version, 0) == "^" end)
          |> Enum.map(fn {name, version} -> {name, replace_major version} end))
      ++
    (Enum.filter(deps, fn {name, version} -> String.at(version, 0) == "~" end) 
          |> Enum.map(fn {name, version} -> {name, replace_minor version} end))
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