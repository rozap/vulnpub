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
        apikeys(
          id serial primary key,
          key varchar(255), 
          user_id integer references users(id),
          created timestamp DEFAULT NOW(), 
          modified timestamp DEFAULT NOW()
        )",
    "CREATE TABLE IF NOT EXISTS
        vulns(
          id serial primary key,
          name varchar(255), 
          description text,
          created timestamp DEFAULT NOW(), 
          modified timestamp DEFAULT NOW()
        )",
    "CREATE TABLE IF NOT EXISTS
        monitors(
          id serial primary key,
          manifest text,
          name text,
          user_id integer references users(id),
          created timestamp DEFAULT NOW(), 
          modified timestamp DEFAULT NOW()
        )",
    "CREATE TABLE IF NOT EXISTS
        packages(
          id serial primary key,
          name text,
          version varchar(255),
          monitor integer references monitors(id),
          created timestamp DEFAULT NOW(), 
          modified timestamp DEFAULT NOW()
        )",
    "CREATE TABLE IF NOT EXISTS
        alerts(
          id serial primary key,
          vuln integer references vulns(id),
          monitor integer references monitors(id),
          created timestamp DEFAULT NOW(), 
          modified timestamp DEFAULT NOW(),
          fulfilled timestamp DEFAULT null
        )"

    ]
  end

  def down do
    ["DROP TABLE IF EXISTS alerts",
     "DROP TABLE IF EXISTS packages",
     "DROP TABLE IF EXISTS monitors",
     "DROP TABLE IF EXISTS apikey", 
     "DROP TABLE IF EXISTS vulns",
     "DROP TABLE IF EXISTS users"]
  end
end
