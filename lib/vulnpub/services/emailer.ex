defmodule Service.Emailer do
  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    Process.register(self, :emailer)
    {:ok, state}
  end

  def handle_call({:get, item}, from, state) do
    {:reply, state[item], state}
  end

end