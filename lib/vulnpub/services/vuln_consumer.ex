defmodule Service.VulnConsumer do
  use GenServer
  import Ecto.Query, only: [from: 2]
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(initial_state) do
    Process.register(self, :vuln_consumer)
    {:ok, initial_state}
  end

  def to_version_list(full_version_name) do
    version = Regex.run(~r/(\.?\d\.?)*/, full_version_name)
      |> List.first
      |> String.split(".")
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(&(String.to_integer &1))      
  end

  def is_effected_package?(package, vuln) do
    to_version_list package.version
  end



  def handle_cast({:create, vuln}, state) do
    :io.format("new vuln created ~n~p~n~p~n~p~n", [vuln.effects_package, vuln.effects_version, vuln.name])
    effected = (from p in Models.Package, where: ilike(p.name, ^vuln.effects_package), select: p)
       |> Repo.all
       |> Enum.filter(fn package -> is_effected_package?(package, vuln) end)

    :io.format("PACKAGES ~p ~n", [effected])


    {:noreply, state}
  end
end