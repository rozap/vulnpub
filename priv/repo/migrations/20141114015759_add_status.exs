defmodule Repo.Migrations.AddStatus do
  use Ecto.Migration

  def up do
    [
      "ALTER TABLE monitors ADD status text DEFAULT 'OK'"
    ]
  end

  def down do
    ""
  end
end
