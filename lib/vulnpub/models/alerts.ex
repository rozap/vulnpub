defmodule Models.Alert do
  use Ecto.Model

  schema "alerts" do
    belongs_to :vuln, Models.Vuln
    belongs_to :monitor, Models.Monitor
    field :created, :datetime
    field :modified, :datetime
    field :fulfilled, :datetime
    field :acknowledged, :boolean
  end

  def adapt(keylist) do
    keylist
  end

  use Vulnpub.Model
end
