defmodule Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def conf do
    parse_url "ecto://vulnpub:lolwut@localhost/vulnpub"
  end

  def priv do
    app_dir(:vulnpub, "priv/repo")
  end
end