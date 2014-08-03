
defmodule Resources.Vuln.Validator do
  
  def ignore_fields(:create), do: [:id] ++ ignore_fields(nil)
  def ignore_fields(_), do: [:created, :modified, :external_link]

  use Resources.ModelValidator, [only: [:create, :update]]
end


defmodule Resources.Vuln.Authenticator do
  use Resources.Authenticator, []
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