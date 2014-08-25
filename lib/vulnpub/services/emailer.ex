defmodule Service.Emailer do
  use GenServer
  use Jazz
  use HTTPotion.Base

  @api "https://mandrillapp.com/api/1.0/"
  @message_send "messages/send.json"
  @js_headers %{"Content-Type" => "application/json"}

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    Process.register(self, :emailer)
    {:ok, state}
  end


  defp interpolate(str, dict) do
    Enum.reduce(dict, str, fn({key, value}, acc) -> 
      String.replace(acc, "#\{" <> Atom.to_string(key) <> "\}", value) end)
  end


  defp post(url, payload) do
    HTTPotion.start
    :io.format("post to ~p ~n body: ~n ~p ~n", [@api <> url, payload])
    HTTPotion.post @api <> url, payload, @js_headers
  end

  defp send(payload) do
    post @message_send, payload
  end

  def handle_cast({:activate, user}, state) do
    template = File.read! "lib/vulnpub/templates/emails/activation.json"
    payload = interpolate(template, %{:key => "some key", :email => user.email, :username => user.username})
    if HTTPotion.Response.success? (send payload) do
      :io.format("Email sent")
    else
      #TODO error handle here
      :io.format("Sending message failed! ~n Email ~p ~n payload ~p ~n", [user.email, payload])
    end
    {:noreply, state}
  end

end