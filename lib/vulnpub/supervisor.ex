defmodule Vulnpub.Supervisor do
  use Supervisor

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    IO.puts("INIT")
    children = [
      worker(Repo, []), 
      worker(Service.MonitorConsumer, [{}, []]),
      worker(Service.VulnConsumer, [{}, []]),
      worker(Service.Config, [[config: "/home/chris/secrets/vp-conf.json"], []])
      worker(Service.Emailer, [[], []])

    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    supervise(children, strategy: :one_for_all)
  end
end
