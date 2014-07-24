defmodule Models.Monitor do
  use Ecto.Model

  schema "monitors" do
    field :manifest
    field :name
    belongs_to :user, Models.User
    field :created, :datetime
    field :modified, :datetime

  end



  def adapt(keylist) do
    keylist
  end


  use Vulnpub.Model
end
