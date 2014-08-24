
defmodule Resources.User.Validator do
  import Ecto.Query, only: [from: 2]

  def validate_field(:create, :username, username) do
    query = from u in Models.User, where: u.username == ^username, select: u
    result = Repo.all(query)
    if length(result) > 0 do
      throw {:bad_request, %{:errors => %{:username => "The username \"#{username}\" is already taken"}}}
    end
    :ok
  end

  use Resources.ModelValidator, [only: [:create, :update]]
end


defmodule Resources.User.Authenticator do
  use Resources.Authenticator, [except: [:create]]
end

defmodule Resources.User.Trigger do
  def handle({:create, conn, status, user}) do
    GenServer.cast(:emailer, {:activate, user})
    {:create, conn, status, user}
  end
  def handle(res), do: res
end


defmodule Resources.User do
  require Resources.Resource

  def model do
    Models.User
  end

  use Resources.Resource, [
    exclude: [:password], 
    middleware: [
      Resources.User.Authenticator,
      Resources.User.Validator
    ], 
    triggers: [
      Resources.User.Trigger
    ]
  ]
end