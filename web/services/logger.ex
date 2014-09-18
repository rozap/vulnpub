defmodule Service.Logger do
  use GenServer
  use Jazz

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init([]) do
    Process.register(self, :logger)
    {:ok, []}
  end

  def handle_cast({level, items},  state) do
    #TODO: actually log to syslog
    :io.format("LOG: ~p~n", [level])
    Enum.map(items, fn {key, val} -> :io.format("| ~p : ~p~n", [key, val]) end)
    Enum.map(1..80, fn _ -> :io.format("-", []) end)
    :io.format("..done..~n~n")
    {:noreply, state}
  end

end