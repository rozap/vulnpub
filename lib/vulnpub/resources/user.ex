
defmodule Resources.User.Validator do
  import Ecto.Query, only: [from: 2]

  def validate_field(:create, :username, username) do
    query = from u in Models.User, where: u.username == ^username, select: u
    result = Repo.all(query)
    if length(result) > 0 do
      throw {:bad_request, [username: "The username #{username} is already taken"]}
    end
    :ok
  end

  use Resources.ModelValidator
end


defmodule Resources.User.Authenticator do
  use Resources.Authenticator, [open: [:index, :create]]
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
      Resources.User.Validator, 
    ]
  ]
end