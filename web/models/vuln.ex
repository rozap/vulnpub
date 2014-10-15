defmodule Models.Vuln do
  use Ecto.Model

  schema "vulns" do
    field :name
    field :description
    field :external_link
    field :created, :datetime
    field :modified, :datetime
  end



  def adapt(keylist) do
    keylist
  end


  use Vulnpub.Model
end
