defmodule Service.VulnConsumer do
  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(initial_state) do
    Process.register(self, :vuln_consumer)
    {:ok, initial_state}
  end


  def handle_cast({:create, vuln}, state) do
    IO.puts("new vuln created")
    {:noreply, state}
  end
end