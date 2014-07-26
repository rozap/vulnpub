defmodule Models.ApiKey do
  use Ecto.Model

  schema "monitors" do
    field :key
    belongs_to :user, Models.User
    field :created, :datetime
    field :modified, :datetime

  end



  def adapt(keylist) do
    keylist
  end


  use Vulnpub.Model
end
