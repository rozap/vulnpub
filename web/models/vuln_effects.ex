defmodule Models.VulnEffect do
  use Ecto.Model

  schema "vuln_effects" do
    belongs_to :vuln, Models.Vuln
    belongs_to :package, Models.Package
    field :vulnerable, :boolean
    field :created, :datetime
    field :modified, :datetime
  end



  def adapt(keylist) do
    keylist
  end


  use Vulnpub.Model
end
