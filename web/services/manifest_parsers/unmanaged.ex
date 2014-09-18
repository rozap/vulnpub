

defmodule Manifest.Parser.Unmanaged do
  # require Manifest.Parser.Parser
  # use Manifest.Parser.Parser
  import Manifest.Parser.Parser



  def parse(node, monitor) do
    Enum.map(node, fn details -> {details["name"], details["version"]} end)
      |> create_packages(monitor)
  end


end