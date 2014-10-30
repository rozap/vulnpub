defmodule Service.Emailer do
  use GenServer
  use Jazz
  use HTTPotion.Base
  require Phoenix.Config
  require Logger
  alias Phoenix.Config


  @api "https://mandrillapp.com/api/1.0/"
  @message_send "messages/send.json"
  @js_headers %{"Content-Type" => "application/json"}
  @email_templates "web/templates/emails/"

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    Process.register(self, :emailer)
    {:ok, state}
  end


  defp interpolate(str, dict) do
    Enum.reduce(dict, str, fn({key, value}, acc) -> 
      String.replace(acc, "#\{" <> Atom.to_string(key) <> "\}", value) 
    end)
  end


  defp post(url, payload) do
    HTTPotion.start
    HTTPotion.post @api <> url, payload, @js_headers
  end

  defp send_email(payload, user) do
    response = post @message_send, payload

    if HTTPotion.Response.success? response do
      Logger.info("Sent email to #{user.email}")
    else
      Logger.error("Failed to send email #{user.email}", [response])
    end
  end

  defp key, do: Config.get!([:vulnpub])[:email_apikey]



  defp handle(:test, _, state) do
    {:noreply, state}
  end



  defp handle(_, {:alert, alert, vuln, package, monitor, user}, state) do
    template = File.read! @email_templates <> "alert.json"

    link = "http://vuln.pub/#vulns/#{vuln.id}"

    payload = interpolate(template, %{
      :key => key, 
      :email => user.email, 
      :username => user.username,
      :vuln_name => vuln.name, 
      :package_name => package.name, 
      :monitor_name => monitor.name,
      :vuln_link => link
    })
    send_email payload, user
    {:noreply, state}
  end


  defp handle(_, {:activate, user}, state) do
    template = File.read! @email_templates <> "activation.json"
    payload = interpolate(template, %{
      key: key, 
      email: user.email, 
      username: user.username
    })
    #send it off...
    send_email payload, user
    {:noreply, state}
  end

  defp handle(_, {:forgot, user, reset}, state) do
    template = File.read! @email_templates <> "forgot.json"
    payload = interpolate(template, %{
      key: key, 
      email: user.email, 
      username: user.username, 
      reset_key: reset.key
    })
    send_email payload, user
    {:noreply, state}
  end



  def handle_cast(thing, state), do: handle(Mix.env, thing, state)
end