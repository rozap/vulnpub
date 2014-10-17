
defmodule Resources.Vuln.Validator do
  import Ecto.Query, only: [from: 2]
  use Finch.Middleware.ModelValidator, [only: [:create, :update]]

  def ignore_fields(:create), do: [:id] ++ ignore_fields(nil)
  def ignore_fields(_), do: [:created, :modified, :external_link]


  def validate_versions(effects) do
    versions = Enum.map(effects, fn effect -> 
        %{"version" => version} = effect
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
        throw {:bad_request, %{:errors => errors}}
      _ -> :ok
    end

    %{name: name, description: description, external_link: link} = params
    query = from v in Models.Vuln, 
              where: 
                v.name == ^name and 
                v.description == ^description and
                v.external_link == ^ link, 
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
        where: ve.vuln_id == ^id,
        select: ve)
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
      effect
        |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
        |> Enum.into(%{})
        |> Dict.put(:vuln_id, id)
        |> VulnEffect.allocate 
        |> repo.insert
    end)
    {conn, _, result} = handle({:show, conn, %{id: "#{id}"}, module, bundle})
    {conn, created, result}
  end

  def handle(req), do: super(req)

end