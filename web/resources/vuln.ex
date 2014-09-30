
defmodule Resources.Vuln.Validator do
  import Ecto.Query, only: [from: 2]
  use Finch.Middleware.ModelValidator, [only: [:create, :update]]

  def ignore_fields(:create), do: [:id] ++ ignore_fields(nil)
  def ignore_fields(_), do: [:created, :modified, :external_link]

  def validate_together(:create, params, bundle) do
    %{:effects_package => ep, :effects_version => ev, :name => name} = params
    query = from v in Models.Vuln, 
              where: v.effects_version == ^ev 
                and v.effects_package == ^ep
                and v.name == ^name, 
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
  def model, do: Models.Vuln

  def page_size, do: 20

end