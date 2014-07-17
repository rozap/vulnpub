defmodule Models.Monitors do
  use Ecto.Model

  schema "monitors" do
    field :manifest
    field :name
    belongs_to :username, Models.User
    field :created, :datetime
    field :modified, :datetime

  end

end


defmodule Models.Monitors.Queries do
  


end