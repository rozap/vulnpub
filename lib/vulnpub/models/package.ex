defmodule Models.Package do
  use Ecto.Model

  schema "packages" do
    field :name
    field :version
    field :created, :datetime
    field :modified, :datetime

  end



  def adapt(keylist) do
    keylist
  end


  use Vulnpub.Model
end
