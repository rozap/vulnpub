defmodule Models.ApiKey do
  use Ecto.Model

  schema "apikeys" do
    field :key
    belongs_to :user, Models.User
    field :created, :datetime
    field :modified, :datetime

  end

  def adapt(keylist) do
    keylist
  end

  def gen_key do
    UUID.uuid4()
  end

  use Vulnpub.Model
end
