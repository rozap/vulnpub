

defmodule Manifest.Parser.RubyGems do
  alias Models.Package
  alias Models.PackageMonitor
  import Manifest.Parser.Parser



  defp parse_version({name, raw_version}) do
    version = find_digits(raw_version)
    {name, version, raw_version}
  end

  def parse_deps body, monitor do
    IO.inspect body
    []
  end


  def parse(filename, details, monitor) do
    get_package_listing(filename, details, monitor)
      |> parse_deps(monitor)
  end
end