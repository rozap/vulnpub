defmodule Service.Stats.CPU do

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def get do
    data = {total, used, _} = :memsup.get_memory_data
    :cpu_sup.util |> Float.end
  end

  defp ms do
    {mega, sec, micro} = :os.timestamp()
    (mega * 1000000 + sec) * 1000 + trunc(micro / 1000)
  end

end