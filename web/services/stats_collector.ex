

defmodule Service.StatsManager do
  use Supervisor
  require Phoenix.Config
  require Logger
  alias Phoenix.Config

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end


  def kids do
    [
      {Service.Stats.Collector, [], []},
      {Task, [fn -> __MODULE__.Flusher.run end], [id: :flusher]},
      {Task, [fn -> __MODULE__.Ticker.run end], [id: :ticker]}
    ]
  end




  ###
  #
  # Collector
  #   * Requests
  #   * Mem
  #   * CPU
  # 

  def init(_) do
    children = Enum.map(kids, fn {svc, args, opts} -> worker(svc, args, opts) end)
    supervise(children, strategy: :one_for_one)
  end


  defmodule Flusher do
    def run do
      Stream.interval(2000)
        |> Stream.map(fn(_) -> IO.puts("FLUSH") end)
        |> Stream.run
    end
  end

  defmodule Ticker do
    def run do
      Stream.interval(1000)
        |> Stream.map(fn(_) -> IO.puts("TICK") end)
        |> Stream.run
    end
  end


end