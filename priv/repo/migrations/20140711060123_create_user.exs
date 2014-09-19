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
          effects_version varchar(255),
          effects_package varchar(255),
          external_link text DEFAULT '',
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
          created timestamp DEFAULT NOW(), 
          modified timestamp DEFAULT NOW()
        )",
    "CREATE TABLE IF NOT EXISTS
        package_monitors(
          id serial primary key,
          monitor_id integer references monitors(id), 
          package_id integer references packages(id)
        )",
    "CREATE TABLE IF NOT EXISTS
        vuln_effects(
          id serial primary key,
          vuln_id integer references vulns(id),
          package_id integer references packages(id), 
          created timestamp DEFAULT NOW(), 
          modified timestamp DEFAULT NOW()
        )",

    "CREATE TABLE IF NOT EXISTS
        alerts(
          id serial primary key,
          vuln_id integer references vulns(id),
          monitor_id integer references monitors(id),
          package_id integer references packages(id),
          created timestamp DEFAULT NOW(), 
          modified timestamp DEFAULT NOW(),
          fulfilled timestamp DEFAULT null,
          acknowledged boolean DEFAULT FALSE
        )"

    ]
  end

  def down do
    ["DROP TABLE IF EXISTS alerts",
     "DROP TABLE IF EXISTS vuln_effects",
     "DROP TABLE IF EXISTS package_monitors",
     "DROP TABLE IF EXISTS packages",
     "DROP TABLE IF EXISTS monitors",
     "DROP TABLE IF EXISTS apikeys", 
     "DROP TABLE IF EXISTS vulns",
     "DROP TABLE IF EXISTS users"]
  end
end
