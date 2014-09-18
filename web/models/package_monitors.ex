defmodule Models.PackageMonitor do
  use Ecto.Model

  schema "package_monitors" do
    belongs_to :package, Models.Package
    belongs_to :monitor, Models.Monitor
  end



  def adapt(keylist) do
    keylist
  end


  use Vulnpub.Model
end
