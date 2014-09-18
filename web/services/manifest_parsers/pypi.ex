

defmodule Manifest.Parser.PyPi do
  # require Manifest.Parser.Parser
  # use Manifest.Parser.Parser
  alias Models.Package
  alias Models.PackageMonitor
  import Manifest.Parser.Parser


  defp parse_line line do
    [name, version] = String.split(line, "==")
    {name, version}
  end

  defp parse_version({name, version}) do
    vnum = String.split(version, "~")
            |> List.first
            |> String.split("-")
            |> List.first
    {name, vnum}
  end

  def parse_deps body, monitor do
    t = String.split(body, "\n")
          |> Enum.filter(fn line -> String.length(line) > 3 end)
          |> Enum.map(&parse_line &1)
          |> Enum.map(&parse_version &1)
          |> create_packages(monitor) 
  end


  def parse(filename, details, monitor) do
    case get_package_listing(filename, details, monitor) do
      {:ok, response} -> parse_deps response.body, monitor
      {:error, response} -> put_error monitor, "Failed to get #{filename}" 
    end
  end
end