defmodule Service.Stats.Flusher do

  def start_link(opts) do
    
  end
  
end

defmodule Service.StatsCollector do
  use Supervisor
  require Phoenix.Config
  alias Phoenix.Config

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end


  def kids do
    [
      Service.Stats.Collector,
      # Service.Stats.Mem,
      Service.Stats.CPU
    ]
  end



  def broadcast_flush do
    freq = Config.get([:vulnpub])[:stats_flush_freq]
    :timer.sleep(freq)
    GenServer.cast(:stats_collector, :flush)
    GenServer.cast(:logger, {:debug, [msg: "Flushing influx data"]})    
    broadcast_flush
  end

  ###
  #
  # Collector
  #   * Requests
  #   * Mem
  #   * CPU
  # 

  def init(_) do
    children = Enum.map(kids, fn k -> worker(k, [[]]) end)
    Task.async(fn -> broadcast_flush end)
    supervise(children, strategy: :one_for_one)
  end



end