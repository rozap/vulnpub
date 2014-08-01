

defmodule Manifest.Parser.NPM do
  # require Manifest.Parser.Parser
  # use Manifest.Parser.Parser

  def parse(filename, details, monitor) do
    location = String.split(monitor.manifest, "/")
      |> Enum.drop(-1)
      |> Enum.concat([filename])
      |> Enum.join("/")
    :io.format("PARSING ~p ~n", [location])
  end
end