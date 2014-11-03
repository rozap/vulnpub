defmodule Manifest.Parser.Parser do

  import Ecto.Query, only: [from: 2]
  alias Models.Package
  alias Models.PackageMonitor
  require Logger

  def get_package(name, version, raw_version) do
    {
      name, 
      version, 
      raw_version,
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



  def create_packages(to_insert, monitor) do
    packages = Enum.map(to_insert, fn {name, version, raw_version} -> 
      get_package(name, version, raw_version) 
    end)
    existing = Enum.filter(packages, fn {_, _, _, p} -> not (is_nil p) end)
    to_create = Enum.filter(packages, fn {_, _, _, p} -> is_nil p end)

    new_packages = to_create
      |> Enum.map(fn {name, version, raw_version, _} -> 
        Package.allocate(%{
          name: name,
          version: version, 
          raw_version: raw_version
        }) 
      end)
    existing = Enum.map(existing, fn {_, _, _, p} -> p end)


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
    Logger.info("Fetching managed file: #{location}")
    HTTPotion.start
    response = HTTPotion.get location
    if HTTPotion.Response.success? response do
      response.body
    else 
      throw :manifest_not_accessible
    end
  end



  @latest ["l", "a", "t", "e", "s", "t"]
  @any "*"



  defp to_version(rest, cb) do
    parsed = Enum.join(rest, "") 
      |> String.strip
      |> Version.Parser.parse_version(true)
    case parsed do
      {:ok, version} -> 
        cb.(version)
      :error -> :error
    end
  end

  def any_patch(rest) do
    to_version(rest, fn {major, minor, _, _} -> "#{major}.#{minor}.*" end)
  end

  def any_minor(rest) do
    to_version(rest, fn {major, _, _, _} -> "#{major}.*.*" end)
  end

  def any(_), do: "*.*.*"


  def to_spec(@any), do: any(@any)
  def to_spec(@latest), do: any(@latest)
  def to_spec([">" | rest]), do: any(rest)
  def to_spec(["<" | rest]), do: any(rest)

  def to_spec(["~", ">" | rest]), do: any_patch(rest)
  def to_spec(["~" | rest]), do: any_patch(rest)

  def to_spec(["^" | rest]), do: any_minor(rest)

  def to_spec(version), do: Enum.join(version, "")



  def find_digits(version) when version == "*.*.*", do: version
  def find_digits(raw_version) do
    case Regex.run(~r/(\d+\.\d+(\.\d+)?)/, raw_version) do
      [version | rest] -> 
        case Version.Parser.parse_version(version, true) do
          {:ok, {major, minor, patch, _}} -> 
            if is_nil(patch) do
              patch = "*"
            end
            "#{major}.#{minor}.#{patch}"
          :error -> 
            Logger.error("find_digits: Failed to parser version #{raw_version}")
            :error
        end

      _ ->
        Logger.error("find_digits: Failed to parser version #{raw_version}")
       :error
    end
  end




end