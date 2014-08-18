

defmodule Resources.Alert.Authenticator do
  use Resources.Authenticator, []
end







defmodule Resources.Alert do
  require Resources.Resource
  import Ecto.Query, only: [from: 2]
  alias Models.Monitor
  alias Models.Alert


  def model, do: Alert

  def handle({:index, conn, params, module, bundle}) do
    %{:user => %{:id => user_id}} = bundle
     result = (from a in Alert,
      join: m in Monitor, on: a.monitor_id == m.id,
      where: m.user_id == ^user_id,
      select: a)
      |> Repo.all
      |> to_serializable
    {conn, ok, result}
  end

	use Resources.Resource, [
    exclude: [], 
    middleware: [Resources.Alert.Authenticator],
    triggers: []
  ]
end