
defmodule Resources.Vuln.Validator do
  import Ecto.Query, only: [from: 2]
  use Finch.Middleware.ModelValidator, [only: [:create, :update]]

  def ignore_fields(:create), do: [:id] ++ ignore_fields(nil)
  def ignore_fields(_), do: [:created, :modified, :external_link]


  def validate_versions(effects) do
    versions = Enum.map(effects, fn effect -> 
        %{"package" => %{"version" => version}} = effect
        case Version.parse_requirement(version) do
          :error ->
            %{version: "#{version} is an invalid version"}
          version -> 
            :ok
        end
      end)
    

    is_ok = Enum.all?(versions, fn res -> res == :ok end)

    if not is_ok do
      {:error, Enum.filter(versions, fn res -> res != :ok end)}
    else
      :ok
    end
  end


  def validate_together(:create, params, bundle) do

    case validate_versions(params[:effects]) do
      {:error, errors} -> 
        IO.inspect {:bad_request, %{:errors => errors}}
        throw {:bad_request, %{:errors => errors}}
      _ -> :ok
    end

    %{:name => name} = params
    query = from v in Models.Vuln, 
              where: v.name == ^name, 
              select: v
    result = Repo.all(query)
    if length(result) > 0 do
      throw {:bad_request, %{:errors => %{:name => "That vulnerability already exists"}}}
    end
    {params, bundle}
  end

end


defmodule Resources.Vuln.Authenticator do
  use Resources.Authenticator, [except: [:index, :show]]
end

defmodule Resources.Vuln.After do
  def handle({:create, conn, status, vuln, module}) do
    GenServer.cast(:vuln_consumer, {:new_vuln, vuln})
    {:create, conn, status, vuln, module}
  end
  def handle(res) do
    res
  end
end



defmodule Resources.Vuln do
  alias Models.Vuln
  alias Models.VulnEffect
  alias Models.Package
  use Finch.Resource, [
    before: [
      Resources.Vuln.Authenticator,
      Resources.Vuln.Validator
    ],
    after: [
      Resources.Vuln.After
    ]  
  ]

  def repo, do: Repo
  def model, do: Vuln

  def page_size, do: 20

  def handle(req = {:show, conn, params, module, bundle}) do
    {conn, ok, result} = super(req)
    id = get_id(params)
    effects = (from ve in VulnEffect, 
        left_join: p in ve.package,
        where: ve.vuln_id == ^id,
        select: assoc(ve, package: p))
        |> Repo.all
        |> Finch.Serializer.to_serializable(VulnEffect, [exclude: []])
    result = Dict.put(result, :effects, effects)
    {conn, ok, result}
  end


  def handle(req = {:create, conn, params, module, bundle}) do
    {effects, params} = Dict.pop(params, :effects)
    {_, _, result} = super({:create, conn, params, module, bundle})
    %{id: id} = result
    effects = Enum.map(effects, fn effect ->

      %{"package" => %{"name" => package_name, "version" => version}} = effect
      package = (from p in Package, 
        where: ilike(p.name, ^package_name) and p.version == ^version, 
        select: p)
        |> Repo.all
        |> List.first

      package = case package do
        nil -> 
          package_params = %{name: package_name, version: version}
          Package.allocate(package_params) |> Repo.insert
        _ -> 
          package
      end

      effect = effect
        |> Dict.delete("package")
        |> Dict.put(:vuln_id, id) 
        |> Dict.put(:package_id, package.id)
      VulnEffect.allocate(effect) |> repo.insert
    end)
    {conn, _, result} = handle({:show, conn, %{id: "#{id}"}, module, bundle})
    {conn, created, result}
  end

end