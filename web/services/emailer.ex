defmodule Service.Emailer do
  use GenServer
  use Jazz
  use HTTPotion.Base
  require Phoenix.Config
  require Logger
  alias Phoenix.Config


  @api "https://mandrillapp.com/api/1.0/"
  @message_send "messages/send.json"
  @js_headers %{"Content-Type" => "application/json; charset=utf-8"}
  @email_templates "web/templates/emails/"
  @email_bodies "web/templates/emails/bodies/"
  @sensitive [:key]

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    Process.register(self, :emailer)
    {:ok, state}
  end


  defp do_interpolate(str, dict) do
    Enum.reduce(dict, str, fn({key, value}, acc) -> 
      String.replace(acc, "#\{" <> Atom.to_string(key) <> "\}", value) 
    end)
  end


  defp to_json_text(str) do
    String.replace(str, "\"", "\\\"")
      |> String.replace("\n", "")
      |> String.replace("\t", "")
  end

  defp interpolate(str, dict) do
    str = do_interpolate(str, Dict.take(dict, @sensitive))
      |> do_interpolate(Dict.drop(dict, @sensitive))
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
      %{"message" => message, "status" => status} = response
      Logger.error("mandrill: Failed to send email #{payload} \n #{user.email} \n status #{status} #{message}")
    end
  end

  defp key, do: Config.get!([:vulnpub])[:email_apikey]



  defp template(filename, bindings) do
    EEx.eval_file(@email_bodies <> "#{filename}.html", bindings)
  end

  defp make_payload(bindings) do
    EEx.eval_file(@email_templates <> "generic.json", bindings)
  end



  defp handle(:test, _, state) do
    {:noreply, state}
  end


  ##
  # alerts = [{vuln, package, alert}]
  defp handle(_, {:alert_digest, alerts, monitor, user}, state) do
    html = to_json_text(template("digest", [alerts: alerts, monitor: monitor, user: user]))
    Logger.debug("Sending alert digest to #{user.username} \n #{html}")
    payload = make_payload([
        key: key,
        user: user,
        html: html,
        subject: "Multiple vulnerabilities affecting your vuln.pub monitor: #{monitor.name}",
        text: html
      ]
    )
    send_email payload, user
    {:noreply, state}
  end





  defp handle(_, {:alert, alert, vuln, package, monitor, user}, state) do

    html = to_json_text(template("alert", [
      alert: alert, 
      vuln: vuln,
      package: package,
      monitor: monitor, 
      user: user
    ]))

    payload = make_payload([
      key: key, 
      user: user, 
      html: html,
      subject: "Vulnerability affecting #{package.name}",
      text: html
    ])

    send_email payload, user
    {:noreply, state}
  end




  defp handle(_, {:activate, user}, state) do


    html = to_json_text(template("activate", [user: user]))

    payload = make_payload([
      key: key, 
      user: user,
      html: html,
      text: html,
      subject: "Thanks for registering at vuln.pub!"
    ])

    #send it off...
    send_email payload, user
    {:noreply, state}
  end

  defp handle(_, {:forgot, user, reset}, state) do

    html = to_json_text(template("forgot", [
      user: user, 
      reset: reset
    ]))

    payload = make_payload([
      key: key, 
      user: user,
      html: html,
      text: html,
      subject: "Reset your vuln.pub password"
    ])

    send_email payload, user
    {:noreply, state}
  end



  def handle_cast(thing, state), do: handle(Mix.env, thing, state)
end