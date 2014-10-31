

defmodule Manifest.Parser.Unmanaged do
  import Manifest.Parser.Parser

  def parse(node, monitor) do
    Enum.map(node, fn details -> {
    	details["name"], 
    	find_digits(details["version"]), 
    	details["version"]
    } end)
      |> create_packages(monitor)
  end


end