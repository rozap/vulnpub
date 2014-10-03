defmodule Plug.Stats do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    url = Enum.join(conn.path_info, "/")
    GenServer.cast(:stats_collector, {conn.method, url})
    conn
  end
end

