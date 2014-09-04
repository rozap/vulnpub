

defmodule Resources.Alert.Authenticator do
  use Resources.Authenticator, []
end







defmodule Resources.Alert do
  require Resources.Resource
  import Ecto.Query, only: [from: 2]
  alias Models.Monitor
  alias Models.Alert
  alias Models.Vuln

  def model, do: Alert
  def page_size, do: 5

  def query({:index, conn, params, module, bundle}) do
    %{:user => %{:id => user_id}} = bundle
     result = (from a in Alert,
      left_join: m in a.monitor,
      left_join: v in a.vuln,
      where: m.user_id == ^user_id and a.acknowledged == false,
      select: assoc(a, monitor: m, vuln: v))
  end

	use Resources.Resource, [
    exclude: [], 
    middleware: [Resources.Alert.Authenticator],
    triggers: []
  ]
end