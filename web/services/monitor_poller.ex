defmodule Service.MonitorPoller do

  import Ecto.Query
  alias Models.Monitor


  def start_link do
    IO.puts "STARTED LINK"
    Task.async(fn -> loop end)
    {:ok, self}
  end

  defp freq, do: GenServer.call(:config, {:get, :monitor_poll_freq})



  defp loop do
    fetch
    :timer.sleep(freq)
    GenServer.cast(:logger, {:debug, [msg: "Updated monitors"]})

    
    loop
  end

  defp fetch do
    last = Util.past([min: 2])
    monitors = (from m in Monitor, where: m.last_polled < ^last, select: m) 
      |> Repo.all
      |> Enum.map(fn mon -> 
          GenServer.cast(:monitor_consumer, {:create, mon})
      end)
  end
 
end