defmodule Models.VulnEffect do
  use Ecto.Model

  schema "vuln_effects" do
    belongs_to :vuln, Models.Vuln
    field :vulnerable, :boolean
    field :version
    field :name
    field :created, :datetime
    field :modified, :datetime
  end



  def adapt(keylist) do
    keylist
  end


  use Vulnpub.Model
end
