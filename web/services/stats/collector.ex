defmodule Service.Stats.Collector do



  use GenServer
  use Jazz

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end


  def init(state) do
    Process.register(self, :stats_collector)
    config = GenServer.call(:config, {:get, :influx_config})
      |> Dict.to_list
      |> Enum.map(fn {key, val} -> {String.to_atom(key), val} end)
      |> Enum.into(%{})
    state = {config, %{}}

    {:ok, state}
  end


  defp ms do
    {mega, sec, micro} = :os.timestamp()
    (mega * 1000000 + sec) * 1000 + trunc(micro / 1000)
  end

  def handle_cast({:insert, table, row},  state) do
    {config, data} = state
    point = [{:time, ms} | row]
    points = [point | Dict.get(data, table, [])]
    data = Dict.put(data, table, points)
    {:noreply, {config, data}}
  end

  defp post_data(_, [], _), do: :ok

  defp post_data(table, points, config) do
    IO.inspect List.first(points)
    columns = List.first(points)
      |> Keyword.keys
      |> Enum.map(&Atom.to_string(&1))

    points = Enum.map(points, &(Keyword.values(&1)))

    js = Jazz.encode!([
      %{
        name: table,
        columns: columns,
        points: points
      }
    ])

    IO.puts js

    HTTPotion.start

    url = "#{config.host}:#{config.port}/db/#{config.db}/series?u=#{config.username}&p=#{config.password}"
    headers = %{"Content-Type" => "application/json"}
    response = HTTPotion.post(url, js, headers)
    if not HTTPotion.Response.success? response do 
      GenServer.cast(:logger, {:error, [msg: "Failed to post to influx"]})
    end
  end


  defp send_series({table, points}, config) do
    Task.async(fn -> post_data(table, points, config) end)
  end

  def handle_cast(:flush, state) do
    {config, data} = state
    data
      |> Dict.to_list
      |> Enum.map(&(send_series(&1, config)))


    {:noreply, {config, %{}}}
  end
end
