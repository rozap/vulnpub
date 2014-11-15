defmodule Plug.Stats do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    before_time = :os.timestamp()
    
    Plug.Conn.register_before_send(conn, fn conn -> 
      params = Dict.to_list(conn.params)
      url = conn.path_info
        |> Enum.map(fn param ->
          case Enum.filter(params, fn {key, value} -> value == param end) do
            [] -> param
            [{key, value}] -> "<#{key}>"
          end
        end)
        |> Enum.join("/")

      after_time = :os.timestamp()
      diff = :timer.now_diff(after_time, before_time) / 1000
      GenServer.cast(:stats_collector, {:insert, "latency", [value: diff, url: url]})
      GenServer.cast(:stats_collector, {:insert, conn.method, [value: 1, url: url]})

      conn
    end)
  end
end

