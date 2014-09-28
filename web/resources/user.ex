
defmodule Resources.User.Validator do
  import Ecto.Query, only: [from: 2]
  use Finch.Middleware.ModelValidator, [only: [:create, :update]]

  def validate_field(:create, :username, username) do
    query = from u in Models.User, where: u.username == ^username, select: u
    result = Repo.all(query)
    if length(result) > 0 do
      throw {:bad_request, %{:errors => %{:username => "The username \"#{username}\" is already taken"}}}
    end
    {:username, username}
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
  def model, do: Models.User

end