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
    #Hash and salt the password here and return the adapted result
    #in the form of a keylist
    Keyword.put(keylist, :password, hash_password(keylist[:password]))
  end


  #do some hash/salt thing here
  def hash_password(password) do
    {:ok, salt} = :bcrypt.gen_salt(10)
    {:ok, hash} = :bcrypt.hashpw(password, salt)
    List.to_string(hash)
  end


  use Vulnpub.Model
end
