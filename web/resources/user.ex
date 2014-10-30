
defmodule Resources.User.Validator do
  import Ecto.Query, only: [from: 2]
  use Finch.Middleware.ModelValidator, [only: [:create, :update]]
  def ignore_fields(:update), do: [:id, :created, :modified, :password, :email, :username]
  def ignore_fields(verb), do: super(verb)

  def validate_field(:create, :username, username) do
    query = from u in Models.User, where: u.username == ^username, select: u
    result = Repo.all(query)
    if length(result) > 0 do
      throw {:bad_request, %{:errors => %{:username => "The username \"#{username}\" is already taken"}}}
    end
    {:username, username}
  end

  def validate_field(verb, :password, val) do
    if String.length(val) < 8 do
      throw {:bad_request, %{errors: %{password: "This needs to be 8 or more characters"}}}
    end
    {:password, val}
  end

  def validate_field(verb, name, val), do: super(verb, name, val)

end


defmodule Resources.User.Authenticator do
  use Resources.Authenticator, [except: [:create]]
end

defmodule Resources.User.Authorizor do
  use Resources.UserAuthorizor, [only: [:update, :delete, :show]]
  
  def model, do: Models.User
  def user_id_attribute, do: :id
end


defmodule Resources.User.After do
  def handle({:create, conn, status, user, module}) do
    GenServer.cast(:emailer, {:activate, user})
    {:create, conn, status, user, module}
  end
  def handle(res), do: res
end


defmodule Resources.User do
  alias Models.User
  use Finch.Resource, [
    exclude: [:password], 
    before: [
      Resources.User.Authenticator,
      Resources.User.Authorizor,
      Resources.User.Validator
    ],
    after: [
      Resources.User.After
    ]
  ]

  def repo, do: Repo
  def model, do: User

  def handle({:update, conn, params, module, bundle}) do
    id = get_id(params)
    params = params
      |> Dict.delete(:id)
      |> Dict.delete(:username)
      |> Dict.delete(:created)
      |> Dict.delete(:modified)
    row = Repo.get(User, id) |> struct(params)
    case row do
      nil -> throw {:not_found, %{error: "That user doesn't exist"}}
      _ -> :ok
    end
    pw = case params[:password] do
      nil -> row.password
      pw -> User.hash_password(pw)
    end
    row = %{row | password: pw}
    Repo.update(row)
    {conn, accepted, to_serializable(row)}
  end

  def handle(req), do: super(req)

end