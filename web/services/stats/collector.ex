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

  def handle_cast({series, value},  state) do
    {config, data} = state
    point = [ms, value]
    points = [point | Dict.get(data, series, [])]
    data = Dict.put(data, series, points)
    {:noreply, {config, data}}
  end


  defp post_data(series_name, points, config) do
    js = Jazz.encode!([
      %{
        name: series_name,
        columns: ["time", "value"],
        points: points
      }
    ])

    HTTPotion.start

    url = "#{config.host}:#{config.port}/db/#{config.db}/series?u=#{config.username}&p=#{config.password}"
    headers = %{"Content-Type" => "application/json"}
    response = HTTPotion.post(url, js, headers)
    if not HTTPotion.Response.success? response do 
      GenServer.cast(:logger, {:error, [msg: "Failed to post to influx"]})
    end
  end


  defp send_series({series_name, points}, config) do
    Task.async(fn -> post_data(series_name, points, config) end)
  end

  def handle_cast(:flush, state) do
    {config, data} = state
    data
      |> Dict.to_list
      |> Enum.map(&(send_series(&1, config)))


    {:noreply, {config, %{}}}
  end
end
