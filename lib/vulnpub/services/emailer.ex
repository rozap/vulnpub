defmodule Service.Emailer do
  use GenServer
  use Jazz

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    Process.register(self, :emailer)
    {:ok, state}
  end

  def handle_cast({:activate, user}, state) do
    key = "foo"
    :io.format("CWD ~p~n", [File.cwd])
    template = File.read! "lib/vulnpub/templates/emails/activation.json"

    :io.format("EMAIL TEMPLATE ~p~n", [template])
    {:noreply, state}
  end

end