
defmodule Resources.ApiKey.Validator do
  import Ecto.Query, only: [from: 2]

  def validate({:create, conn, params, module, bundle}) do
    try do
      %{:username => username, :password => password} = params
      [user] = (from u in Models.User, where: u.username == ^username, select: u) |> Repo.all
      {:ok, provided_hash} = hashed = :bcrypt.hashpw(password, user.password)
      if List.to_string(provided_hash) != user.password do
        raise :invalid
      end
    rescue
      _ -> throw {:bad_request, %{:errors => %{:username => "The username/password combination is invalid"}}}
    end
    {:create, conn, params, module, bundle}
  end
  use Resources.ModelValidator, [only: [:create]]
end


defmodule Resources.ApiKey.Authenticator do
  use Resources.Authenticator, [only: [:show]]
end

defmodule Resources.ApiKey.Authorizor do
  import Ecto.Query

  def handle({:show, conn, params, module, bundle}) do
    try do
      user_id = bundle[:user].id
      key = params[:id]
      [monitor] = (from a in Models.ApiKey, where: a.user_id == ^user_id and a.key == ^key, select: a) |> Repo.all
      {:show, conn, params, module, bundle}
    rescue
      _ -> throw {:unauthorized, %{error: "You are not authorized to do that"}}
    end

  end

  use Resources.ModelAuthorizor, [only: [:show]]
end


defmodule Resources.ApiKey do
  import Phoenix.Controller
  import Ecto.Query


  def id_field, do: :key
  def get_id(params), do: params[:id]

  def model, do: Models.ApiKey


  def handle({:create, conn, params, module, bundle}) do
    %{:username => username, :password => password} = params
    [user] = (from u in Models.User, where: u.username == ^username, select: u) |> Repo.all
    props = %{:user_id => user.id, :key => Models.ApiKey.gen_key}
    key = Models.ApiKey.allocate(props) |> Repo.insert |> to_serializable
    {conn, created, key}
  end




  import Resources.Resource
  use Resources.Resource, [
    exclude: [],
    middleware: [
      Resources.ApiKey.Validator, 
      Resources.ApiKey.Authenticator,
      Resources.ApiKey.Authorizor
    ]
  ]
end