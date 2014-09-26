defmodule Service.VulnConsumer do
  use GenServer
  import Ecto.Query, only: [from: 2]

  alias Models.PackageMonitor
  alias Models.Package
  alias Models.Monitor
  alias Models.Alert
  alias Models.User

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
    to_version_list(package.version) <= to_version_list(vuln.effects_version)
  end


  defp create_monitor_alert(monitor_id, package_id, vuln) do
    alert = Alert.allocate(%{:monitor_id => monitor_id, :vuln_id => vuln.id, :package_id => package_id}) 
      |> Repo.insert

    package = Repo.get(Package, package_id)
    monitor = Repo.get(Monitor, monitor_id)
    user = Repo.get(User, monitor.user_id)
    GenServer.cast(:emailer, {:alert, alert, vuln, package, monitor, user})
    GenServer.cast(:logger, {:debug, [message: "created alert", user: user.username, package: package.name]})
  end

  defp create_alert(package, vuln) do
    monitors = (from pm in PackageMonitor, 
      where: pm.package_id == ^package.id, 
      select: pm)
      |> Repo.all
      |> Enum.map(&(create_monitor_alert &1.monitor_id, &1.package_id, vuln))

  end


  def handle_cast({:create, vuln}, state) do
    effected = (from p in Package, where: ilike(p.name, ^vuln.effects_package), select: p)
       |> Repo.all
       |> Enum.filter(fn package -> is_effected_package?(package, vuln) end)
       |> Enum.map(&(create_alert &1, vuln))


    {:noreply, state}
  end
end