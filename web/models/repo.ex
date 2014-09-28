defmodule Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def conf do
    parse_url "ecto://vulnpub:lolwut@localhost/vulnpub"
  end

  def priv do
    app_dir(:vulnpub, "priv/repo")
  end

  def log({:query, sql}, fun) do
    {time, result} = :timer.tc(fun)
    # :io.format("SQL ~n~p~n", [sql])
    result
  end

  def log(_arg, fun), do: fun.()

end