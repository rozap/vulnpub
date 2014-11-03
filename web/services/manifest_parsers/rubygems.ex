

defmodule Manifest.Parser.RubyGems do
  alias Models.Package
  alias Models.PackageMonitor
  import Manifest.Parser.Parser
  require Logger


  defp parse_version({name, raw_version}) do
    version = find_digits(raw_version)
    {name, version, raw_version}
  end

  defp parse_line(line) do
    case Regex.run(~r/gem "([\w-]+)"(, "([~><= \d.]+)"?)?/, line) do
      [_, name] -> {name, "*.*.*", "*.*.*"}
      [_, name, _, raw_version] -> 
        version = String.split(raw_version, "", trim: true) |> to_spec
        {name, version, raw_version}
        IO.puts "name #{name} version #{version} rv #{raw_version}"
        {name, version, raw_version}
      wut -> 
        # Logger.info("Can't parse #{line}")
        {:error, :error, :error}
    end
  end

  def parse_deps body, monitor do
    String.split(body, "\n")
      |> Enum.map(fn line -> parse_line(line) end)
  end


  def parse(filename, details, monitor) do
    get_package_listing(filename, details, monitor)
      |> parse_deps(monitor)
      |> Enum.filter(fn {_, version, _} -> version != :error end)
      |> create_packages(monitor)
  end
end