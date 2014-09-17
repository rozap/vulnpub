defmodule Vulnpub do
  use Application

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    :application.start(:crypto)
    :application.start(:bcrypt)
    Vulnpub.Supervisor.start_link
  end
end
