defmodule Models.Package do
  use Ecto.Model

  schema "monitors" do
    field :name
    belongs_to :manifest, Models.Manifest
    field :version
    field :created, :datetime
    field :modified, :datetime

  end



  def adapt(keylist) do
    keylist
  end


  use Vulnpub.Model
end
