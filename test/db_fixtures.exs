defmodule Fixture do
  import Ecto.Query, only: [from: 2]
  require Models.User
  require Models.Monitor

  defp delete(model) do
    Repo.delete_all(model)
    # query = from m in model, select: m
    # rows = Repo.all(query)
    # if length(rows) > 0 do
    #   Repo.delete_all(rows)
    # end
  end

  def load do
    IO.puts("Loading fixture") 
    delete Models.ApiKey   
    delete Models.Monitor
    delete Models.User
  end

end