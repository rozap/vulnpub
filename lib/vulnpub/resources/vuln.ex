
defmodule Resources.Vuln.Validator do
  import Ecto.Query, only: [from: 2]

  def ignore_fields(:create), do: [:id] ++ ignore_fields(nil)
  def ignore_fields(_), do: [:created, :modified, :external_link]

  def validate_together(:create, params, _) do
    %{:effects_package => ep, :effects_version => ev, :name => name} = params
    query = from v in Models.Vuln, 
              where: v.effects_version == ^ev 
                and v.effects_package == ^ep
                and v.name == ^name, 
              select: v
    result = Repo.all(query)
    if length(result) > 0 do
      throw {:bad_request, %{:name => "The vulnerability already exists"}}
    end
    :ok
  end

  use Resources.ModelValidator, [only: [:create, :update]]
end


defmodule Resources.Vuln.Authenticator do
  use Resources.Authenticator, [except: [:index, :show]]
end

defmodule Resources.Vuln.Trigger do
  def handle({:create, conn, status, vuln}) do
    GenServer.cast(:vuln_consumer, {:create, vuln})
    {:create, conn, status, vuln}
  end
  def handle(res), do: res
end



defmodule Resources.Vuln do
  require Resources.Resource

  def model do
    Models.Vuln
  end

	use Resources.Resource, [
    middleware: [
      Resources.Vuln.Authenticator,
      Resources.Vuln.Validator
    ], 
    triggers: [
      Resources.Vuln.Trigger
    ]
  ]
end