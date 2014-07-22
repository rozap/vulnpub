defmodule Models.User do
  use Ecto.Model
  
  schema "users" do
    field :username, :string
    field :password, :string
    field :email, :string
    field :created, :datetime
    field :modified, :datetime
  end

  def adapt(keylist) do
    :io.format("KEYLIST CALLED ~p~n", [keylist])
    keylist
  end





  use Vulnpub.Model
end
