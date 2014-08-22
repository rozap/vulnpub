defmodule Service.Config do
  use GenServer
  use Jazz

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init([config: path]) do
    Process.register(self, :config)
    txt = File.read! path
    js =JSON.decode! txt
    :io.format("conf ~p~n", [js])
    {:ok, js}
  end

  def handle_call({:get, item}, from, state) do
    {:reply, state[item], state}
  end

end