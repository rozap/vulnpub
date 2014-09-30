

defmodule Manifest.Parser.Dpkg do
  alias Models.Package
  alias Models.PackageMonitor
  import Manifest.Parser.Parser


  defp parse_line line do
    toks = String.split(line, " ")
      |> Enum.filter(fn token -> token != "" end)

    if length(toks) > 3 do
      [_, name, version | tl] = toks
      {name, version}
    else
      :error
    end
  end


  defp remove_words version do
    Regex.split(~r/\.[A-Za-z]/, version) |> List.first
  end


  defp parse_version({name, version}) do
    vnum = String.split(version, "~")
            |> List.first
            |> String.split("-")
            |> List.first
            |> remove_words
    {name, vnum}
  end

  def parse_deps body, monitor do
    String.split(body, "\n")
      |> Enum.drop(5)
      |> Enum.map(&parse_line &1)
      |> Enum.filter(fn val -> val != :error end)
      |> Enum.map(&parse_version &1)
      |> create_packages(monitor) 
  end


  def parse(filename, details, monitor) do
    get_package_listing(filename, details, monitor)
      |> parse_deps(monitor)
  end
end