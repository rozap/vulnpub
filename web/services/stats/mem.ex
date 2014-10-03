defmodule Service.Stats.Mem do


  def start_link() do
    stream = Stream.interval(1000)
      |> Stream.map(&(get &1))
      |> Stream.map(&(put &1))

    Process.link(self)
    {:ok, self}
  end


  def get(_) do
    # data = {total, used, _} = :memsup.get_memory_data
    # Float.round(100 * used/total, 2)
  end

  def put(_) do
    IO.format("PUTTING")
  end

end