defmodule Service.VulnConsumer do
  use GenServer
  import Ecto.Query, only: [from: 2]

  alias Models.PackageMonitor
  alias Models.Package
  alias Models.Monitor
  alias Models.Alert
  alias Models.User
  alias Models.Vuln

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(initial_state) do
    Process.register(self, :vuln_consumer)
    {:ok, initial_state}
  end

  # def to_version_list(full_version_name) do
  #   version = Regex.run(~r/(\.?\d\.?)*/, full_version_name)
  #     |> List.first
  #     |> String.split(".")
  #     |> Enum.filter(&(&1 != ""))
  #     |> Enum.map(&(String.to_integer &1))
  # end

  def is_effected_package?(package, vuln) do
    package.version <= vuln.effects_version
  end


  defp create_monitor_alert(monitor_id, package_id, vuln) do
    case (from a in Alert, where: a.monitor_id == ^monitor_id, select: a) |> Repo.all do
      [existing] -> GenServer.cast(:logger, {:debug, 
          [
            message: "alert already exists", 
            alert: existing.id 
          ]
        })
      [] -> 
        alert = Alert.allocate(%{:monitor_id => monitor_id, :vuln_id => vuln.id, :package_id => package_id}) 
          |> Repo.insert

        package = Repo.get(Package, package_id)
        monitor = Repo.get(Monitor, monitor_id)
        user = Repo.get(User, monitor.user_id)
        GenServer.cast(:emailer, {:alert, alert, vuln, package, monitor, user})
        GenServer.cast(:logger, {:debug, 
          [
            message: "created alert", 
            user: user.username, 
            package: package.name
          ]
        })
    end
  end

  defp create_alert(package, vuln) do
    monitors = (from pm in PackageMonitor, 
      where: pm.package_id == ^package.id, 
      select: pm)
      |> Repo.all
      |> Enum.map(&(create_monitor_alert &1.monitor_id, &1.package_id, vuln))

  end


  def handle_cast({:new_vuln, vuln}, state) do
    effected = (from p in Package, where: ilike(p.name, ^vuln.effects_package), select: p)
       |> Repo.all
       |> Enum.filter(fn package -> is_effected_package?(package, vuln) end)
       |> Enum.map(&(create_alert &1, vuln))
    {:noreply, state}
  end

  ##
  # Select 
  #
  # def handle_cast({:new_monitor, monitor}, state) do

    # (from v in Vuln,)

  #   packages = (from pm in PackageMonitor,
  #     join: p in Package, on: pm.package_id == p.id,
  #     where: pm.monitor_id == ^id,
  #     select: p)



  #   effected = (from p in Package, where: ilike(p.name, ^vuln.effects_package), select: p)
  #      |> Repo.all
  #      |> Enum.filter(fn package -> is_effected_package?(package, vuln) end)
  #      |> Enum.map(&(create_alert &1, vuln))
  #   {:noreply, state}
  # end


end