defmodule Service.Stats.CPU do

  def start_link(opts \\ []) do
    GenEvent.start_link Keyword.put_new(opts, :name, __MODULE__)

    Stream.interval(1000)
      |> get
      |> send
    {:ok, self}
  end

  def get(_) do
    data = {total, used, _} = :memsup.get_memory_data
    :cpu_sup.util |> Float.round
  end

  def send(value) do
    GenServer.cast(:stats_collector, {:insert, "cpu", [value: value]})
  end

  defp ms do
    {mega, sec, micro} = :os.timestamp()
    (mega * 1000000 + sec) * 1000 + trunc(micro / 1000)
  end

end