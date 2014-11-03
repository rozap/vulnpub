

defmodule Manifest.Parser.PyPi do
  alias Models.Package
  alias Models.PackageMonitor
  import Manifest.Parser.Parser


  defp parse_line line do
    [name, version] = String.split(line, "==")
    {name, version}
  end

  defp parse_version({name, raw_version}) do
    vnum = find_digits(raw_version)
    {name, vnum, raw_version}
  end

  def parse_deps body, monitor do
    String.split(body, "\n")
      |> Enum.filter(fn line -> String.length(line) > 3 end)
      |> Enum.map(&parse_line &1)
      |> Enum.map(&parse_version &1)
      |> create_packages(monitor) 
  end


  def parse(filename, details, monitor) do
    get_package_listing(filename, details, monitor)
      |> parse_deps(monitor)
  end
end