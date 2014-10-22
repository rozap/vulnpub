defmodule Service.Stats.CPU do
  use GenEvent

  def handle_event(:tick, parent) do
    GenServer.cast(:stats_collector, {:insert, "cpu", [value: get]})
    {:ok, parent}
  end

  defp get do
    :cpu_sup.util |> Float.round
  end

end