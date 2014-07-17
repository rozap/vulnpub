defmodule Repo.Migrations.CreateUser do
  use Ecto.Migration

  def up do
    ["CREATE TABLE IF NOT EXISTS
        users(
          id serial primary key,
          username varchar(32), 
          password text, 
          email text, 
          created timestamp DEFAULT NOW(), 
          modified timestamp DEFAULT NOW()
        )",
    "CREATE TABLE IF NOT EXISTS
        monitors(
          id serial primary key,
          manifest text,
          name text,
          username integer references users(id),
          created timestamp DEFAULT NOW(), 
          modified timestamp DEFAULT NOW()
        )"
    ]
  end

  def down do
    ["DROP TABLE IF EXISTS monitors", "DROP TABLE IF EXISTS users"]
  end
end
