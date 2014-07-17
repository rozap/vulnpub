defmodule Controllers.Users do
  use Phoenix.Controller
  import Ecto.Query, only: [from: 2]
  alias Models.User, as: User


  def index(conn, params) do
    query = from u in User, select: u
    result = Repo.all(query)
    json conn, Resource.resp(result)
  end

  def create(conn, params) do
    :io.format("PARAMS ~p~n", [params])
    user = Resource.from_json(params)
  	user = User.__schema__(:allocate, params)
  	user = Repo.insert(user)
  	json conn, Resource.resp(user)
  end
end