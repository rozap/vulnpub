defmodule Service.MonitorPoller do

  import Ecto.Query
  alias Models.Monitor
  require Phoenix.Config
  alias Phoenix.Config


  def start_link do
    freq = Config.get!([:vulnpub])[:monitor_poll_freq]
    IO.puts "POLLING FOR #{freq}"
    Task.async(fn -> loop(freq) end)
    {:ok, self}
  end


  defp loop(freq) do
    fetch
    :timer.sleep(freq)
    GenServer.cast(:logger, {:debug, [msg: "Updated monitors"]})
    loop(freq)
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