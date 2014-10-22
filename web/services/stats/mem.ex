defmodule Service.Stats.Mem do
  use GenEvent

  def handle_event(:tick, parent) do
    GenServer.cast(:stats_collector, {:insert, "mem", [value: get]})
    {:ok, parent}
  end

  def get do
    data = {total, used, _} = :memsup.get_memory_data
    Float.round(100 * used/total, 2)
  end

end