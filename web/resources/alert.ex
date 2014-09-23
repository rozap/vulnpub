

defmodule Resources.Alert.Authenticator do
  use Resources.Authenticator, []
end







defmodule Resources.Alert do
  import Ecto.Query
  alias Models.Monitor
  alias Models.Alert
  alias Models.Vuln

  use Finch.Resource, [
    before: [
      Resources.Alert.Authenticator
    ]
  ]

  def repo, do: Repo
  def model, do: Alert
  def page_size, do: 5

  def resource_query({:index, _, _, _, bundle}) do
    %{:user => %{:id => user_id}} = bundle
     result = (from a in Alert,
      left_join: m in a.monitor,
      left_join: v in a.vuln,
      left_join: p in a.package,
      where: m.user_id == ^user_id and a.acknowledged == false,
      select: assoc(a, monitor: m, vuln: v, package: p))
  end

  def resource_query(req), do: super(req)

  def index_size({:index, _, _, _, bundle}) do
    %{:user => %{:id => user_id}} = bundle
    (from a in Alert,
      left_join: m in a.monitor,
      where: m.user_id == ^user_id and a.acknowledged == false,
      select: count(m.id)) |> Repo.all
  end

  def index_size(req), do: super(req)

  

end