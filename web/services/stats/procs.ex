defmodule Service.Stats.Procs do
  use GenEvent

  def handle_event(:tick, parent) do
    GenServer.cast(:stats_collector, {:insert, "procs", [value: get]})
    {:ok, parent}
  end

  def get do
  	length(Process.list)
  end

end