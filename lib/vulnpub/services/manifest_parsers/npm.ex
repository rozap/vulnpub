

defmodule Manifest.Parser.NPM do
  # require Manifest.Parser.Parser
  # use Manifest.Parser.Parser
  import Manifest.Parser.Parser



  
  def parse_deps(jsobj, monitor) do
    create_packages jsobj["dependencies"], monitor
  end

  def parse(filename, details, monitor) do
    case get_package_listing(filename, details, monitor) do
      {:ok, response} -> 
        case JSON.decode response.body do
          {:ok, jsobj} -> parse_deps jsobj, monitor
          _ -> put_error monitor, "Failed to parse json" 
        end
      {:error, _} -> put_error monitor, "Failed to get #{filename}" 
    end
  end
end