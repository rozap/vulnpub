defmodule Fixture do
  import Ecto.Query, only: [from: 2]
  require Models.User
  require Models.Monitor

  defp delete(model) do
    Repo.delete_all(model)
  end

  def load do
    IO.puts("Loading fixture") 
    delete Models.Alert
    delete Models.PackageMonitor
    delete Models.Package
    delete Models.ApiKey   
    delete Models.Monitor
    delete Models.User
    delete Models.Vuln
  end

end