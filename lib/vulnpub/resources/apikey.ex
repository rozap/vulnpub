
defmodule Resources.ApiKey.Validator do
  import Ecto.Query, only: [from: 2]


  def validate(:create, conn, params, module) do
    :io.format("~p~n", [params])
    %{:username => username, :password => password} = params
    hashed = Models.User.hash_password(password)
    query = from u in Models.User, where: u.username == ^username and u.password == ^hashed, select: u
    result = Repo.all(query)
    if length(result) == 0 do
      throw {:bad_request, [username: "The username/password combination is invalid"]}
    end
    :io.format("u: ~p p ~p ~n", [username, password])
    :ok
  end
  use Resources.ModelValidator
end


defmodule Resources.ApiKey do
  import Phoenix.Controller
  import Ecto.Query



  def handle(:create, conn, params) do
    %{:username => username, :password => password} = params
    [user] = (from u in Models.User, where: u.username == ^username, select: u) |> Repo.all
    props = %{:user_id => user.id, :key => Models.ApiKey.gen_key}
    key = Models.ApiKey.allocate(props) |> Repo.insert
    json conn, serialize(key)
  end




  import Resources.Resource
  use Resources.Resource, [
    exclude: [],
    middleware: [
      Resources.ApiKey.Validator
    ]
  ]


  def model do
    Models.ApiKey
  end

end