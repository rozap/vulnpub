defmodule Service.Stats.Collector do
  require Logger
  require Phoenix.Config
  alias Phoenix.Config
  use GenServer
  use Jazz

  def start_link(opts \\ 0) do
    GenServer.start_link(__MODULE__, opts)
  end


  def init(state) do
    Process.register(self, :stats_collector)
    config = Config.get([:influx])
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

    HTTPotion.start

    url = "#{config.host}:#{config.port}/db/#{config.dbname}/series?u=#{config.username}&p=#{config.password}"
    headers = %{"Content-Type" => "application/json"}
    response = HTTPotion.post(url, js, headers)
    if not HTTPotion.Response.success? response do 
      Logger.error "Failed to post to influx"
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
