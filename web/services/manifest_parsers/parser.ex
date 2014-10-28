defmodule Manifest.Parser.Parser do

  import Ecto.Query, only: [from: 2]
  alias Models.Package
  alias Models.PackageMonitor

  def get_package(name, version) do
    {
      name, 
      version, 
      (from p in Package, 
        where: p.name == ^name and p.version == ^version, 
        select: p) 
      |> Repo.all 
      |> List.first
    }
  end


  def create_package_monitors(monitor, packages) do
    Enum.map(packages, fn package -> 
      PackageMonitor.allocate(%{
        :package_id => package.id, 
        :monitor_id => monitor.id
      })
      end)
  end



  def create_packages keylist, monitor do
    packages = Enum.map(keylist, fn {name, version} -> get_package(name, version) end)
    existing = Enum.filter(packages, fn {_, _, p} -> not (is_nil p) end)
    to_create = Enum.filter(packages, fn {_, _, p} -> is_nil p end)

    new_packages = to_create
      |> Enum.map(fn {name, version, _} -> 
        {name, extract_version(version)} end)
      |> Enum.filter(fn {name, version} -> 
        version != :error end)
      |> Enum.map(fn {name, version} -> 
        Package.allocate(%{:name => name, :version => version}) 
      end)
    existing = Enum.map(existing, fn {_, _, p} -> p end)


    {:ok, packages} = Repo.transaction(fn -> 
      Enum.map(new_packages, 
        fn m -> Repo.insert(m) end) 
    end)


    create_package_monitors(monitor, packages ++ existing)
  end




  defp extract_version(version) do

    case Version.parse(version) do
      {:ok, v} -> 
        "#{v.major}.#{v.minor}.#{v.patch}"
      :error -> version
        ## attempt to fix it
        # case Regex.run(~r/(\d+\.\d+\(.\d+)?)/, version) do
        #   nil ->
        #     case Regex.run(~r/(\d+\.\d+)/, version) do
        #       nil -> 
        #       versions ->
        #         v = List.first(versions)
        #         "#{v}.*"
        #     end
        #   versions -> List.first(versions)
        # end
    end
  end
  

  def get_package_listing(filename, details, monitor) do
    location = String.split(monitor.manifest, "/")
      |> Enum.drop(-1)
      |> Enum.concat([filename])
      |> Enum.join("/")

    HTTPotion.start
    response = HTTPotion.get location
    if HTTPotion.Response.success? response do
      response.body
    else 
      throw :manifest_not_accessible
    end
  end

end