

defmodule Service.StatsManager do
  use Supervisor
  require Phoenix.Config
  require Logger
  alias Phoenix.Config

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  ###
  #
  # Collector
  #   * Requests
  #   * Mem
  #   * CPU
  # 

  def init(_) do
    {:ok, manager} = GenEvent.start_link

    GenEvent.add_handler(manager, Service.Stats.CPU, self)
    GenEvent.add_handler(manager, Service.Stats.Mem, self)
    GenEvent.add_handler(manager, Service.Stats.Procs, self)

    timers = Enum.map([
      {__MODULE__.Flusher, :flusher},
      {__MODULE__.Ticker, :ticker}
    ], fn {module, id} -> 
      worker(Task, [fn -> module.run(manager) end], [id: id]) end)

    children = [
        worker(Service.Stats.Collector, [[]])
    ] ++ timers
    supervise(children, strategy: :one_for_one)
  end


  defmodule Flusher do
    def run(manager) do
      flush_interval = Config.get!([:vulnpub])[:stats_flush_freq]
      Stream.interval(flush_interval)
        |> Stream.map(fn(_) -> GenServer.cast(:stats_collector, :flush) end)
        |> Stream.run
    end
  end

  defmodule Ticker do
    def run(manager) do
      tick_interval = Config.get!([:vulnpub])[:stats_tick_freq]
      Stream.interval(tick_interval)
        |> Stream.map(fn(_) -> GenEvent.notify(manager, :tick) end)
        |> Stream.run
    end
  end


end