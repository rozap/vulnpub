
defmodule Resources.ApiKey.Validator do
  import Ecto.Query, only: [from: 2]

  def validate({:create, conn, params, module, bundle}) do
    try do
      %{:username => username, :password => password} = params
      hashed = Models.User.hash_password(password)
      query = from u in Models.User, where: u.username == ^username and u.password == ^hashed, select: u
      [result] = Repo.all(query)
    rescue
      _ -> throw {:bad_request, %{:username => "The username/password combination is invalid"}}
    end
    {:create, conn, params, module, bundle}
  end
  use Resources.ModelValidator, [only: [:create]]
end


defmodule Resources.ApiKey do
  import Phoenix.Controller
  import Ecto.Query

  def handle({:create, conn, params, module, bundle}) do
    %{:username => username, :password => password} = params
    [user] = (from u in Models.User, where: u.username == ^username, select: u) |> Repo.all
    props = %{:user_id => user.id, :key => Models.ApiKey.gen_key}
    key = Models.ApiKey.allocate(props) |> Repo.insert |> to_serializable
    {conn, created, key}
  end

  def handle({:destroy, conn, params, module, bundle}) do
    key = params[:id]
    [row] = (from a in model, where: a.key == ^key, select: a) |> Repo.all 
    Repo.delete(row)
    {conn, accepted, to_serializable(row)}
  end

  def model do
    Models.ApiKey
  end



  import Resources.Resource
  use Resources.Resource, [
    exclude: [],
    middleware: [
      Resources.ApiKey.Validator
    ]
  ]
end