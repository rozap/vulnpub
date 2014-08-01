defmodule Service.MonitorConsumer do
  use GenServer

  def start_link(state, opts) do
    # 1. Pass the buckets supevisor as argument
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(initial_state) do
    Process.register(self, :monitor_consumer)
    IO.puts("Consumer has registered")
    {:ok, initial_state}
  end



  defp make_packages jsobj do
    :io.format("~p~n", [jsobj])
  end

  def handle_cast({:create, monitor}, state) do
    HTTPotion.start
    response = HTTPotion.get monitor.manifest
    if HTTPotion.Response.success? response do
      case  JSON.decode response.body do
        {:ok, jsobj} -> make_packages jsobj
        _ -> :io.format("malformed json")
      end
    else
      :io.format("manifest failed, not accessible~n")
    end
    {:noreply, state}
  end
end