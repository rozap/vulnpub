defmodule Models.User do
  use Ecto.Model

  schema "users" do
    field :username
    field :password
    field :email
    field :created, :datetime
    field :modified, :datetime
  end

end


defmodule Models.User.Queries do
  


end