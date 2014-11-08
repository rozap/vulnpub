defmodule Vulnpub do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Repo, []), 
      worker(Service.MonitorConsumer, [{}, []]),
      worker(Service.VulnConsumer, [{}, []]),
      worker(Service.Emailer, [[], []]),
      worker(Service.MonitorPoller, []),
      worker(Service.StatsManager, [[]])
    ]

    Logger.add_backend({Logger.Backends.Syslog, :syslog})

    :application.start(:crypto)
    :application.start(:bcrypt)
    opts = [strategy: :one_for_one, name: Vulnpub.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
