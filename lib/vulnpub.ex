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
      worker(Service.Logger, [[], []]),
      worker(Service.MonitorPoller, []),
      worker(Service.StatsCollector, [[]])
    ]

    :application.start(:crypto)
    :application.start(:bcrypt)
    GenEvent.add_handler(Logger, Logger.Backends.Syslog, [])

    opts = [strategy: :one_for_one, name: Vulnpub.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
