defmodule Manifest.Parser.Parser do

  import Ecto.Query, only: [from: 2]
  alias Models.Package
  alias Models.PackageMonitor

  def get_package(name, version) do
    (from p in Package, where: p.name == ^name and p.version == ^version, select: p) |> Repo.all |> List.first
  end


  def create_package_monitors(monitor, packages) do
    IO.inspect monitor
    package_monitors = Enum.map(packages, fn package -> 
      IO.inspect package
      PackageMonitor.allocate(%{
        :package_id => package.id, 
        :monitor_id => monitor.id
      })
      end)
    {:ok, _} = Repo.transaction(fn -> 
      Enum.map(package_monitors, 
        fn pm -> Repo.insert(pm) 
      end)
    end)
  end



  def create_packages keylist, monitor do
    {to_create, existing} = Enum.map(keylist, fn {name, version} -> {name, version, get_package(name, version)} end)
      |> Enum.split_while(fn {_, _, existing} -> existing == nil end)

    new_packages = Enum.map(to_create, fn {name, version, _} -> Package.allocate(%{:name => name, :version => version}) end)
    existing = Enum.map(existing, fn {_, _, p} -> p end)


    {:ok, packages} = Repo.transaction(fn -> 
      Enum.map(new_packages, 
        fn m -> Repo.insert(m) end) 
    end)
    create_package_monitors(monitor, packages ++ existing)
  end

  

  def get_package_listing(filename, details, monitor) do
    location = String.split(monitor.manifest, "/")
      |> Enum.drop(-1)
      |> Enum.concat([filename])
      |> Enum.join("/")

    HTTPotion.start
    response = HTTPotion.get location
    if HTTPotion.Response.success? response do
      {:ok, response}
    else 
      {:error, response}
    end
  end

end