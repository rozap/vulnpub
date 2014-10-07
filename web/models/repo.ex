defmodule Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres
  require Phoenix.Config
  alias Phoenix.Config

  def conf do
    dbname = Config.get!([:database])[:dbname]
    host = Config.get!([:database])[:host]
    username = Config.get!([:database])[:username]
    password = Config.get!([:database])[:password]
    IO.puts "ecto://#{username}:#{password}@#{host}/#{dbname}"
    parse_url "ecto://#{username}:#{password}@#{host}/#{dbname}"
  end

  def priv do
    app_dir(:vulnpub, "priv/repo")
  end

  def log({:query, sql}, fun) do
    {time, result} = :timer.tc(fun)
    result
  end

  def log(_arg, fun), do: fun.()

end