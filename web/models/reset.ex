
defmodule Models.Reset do
  use Ecto.Model

  schema "resets" do
    field :key
    belongs_to :user, Models.User
    field :created, :datetime
    field :modified, :datetime
  end



  def adapt(keylist), do: keylist

  def gen_key do
    UUID.uuid4()
  end


  use Vulnpub.Model
end
