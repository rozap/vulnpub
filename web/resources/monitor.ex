
defmodule Resources.Monitor.Validator do
  use Finch.Middleware.ModelValidator, [only: [:create, :update]]
  def ignore_fields(_), do: [:id, :created, :modified, :user_id]
end


defmodule Resources.Monitor.Authenticator do
  use Resources.Authenticator, []
end


defmodule Resources.Monitor.Authorizor do
  import Ecto.Query, only: [from: 2]

  def check({verb, conn, params, module, bundle}) do
    try do
      user_id = bundle[:user].id
      id = String.to_integer params[:id]
      [monitor] = (from m in Models.Monitor, where: m.user_id == ^user_id and m.id == ^id, select: m) |> Repo.all
      {verb, conn, params, module, bundle}
    rescue
      _ -> throw {:unauthorized, %{error: "You are not authorized to do that"}}
    end
  end

  def handle({:update, conn, params, module, bundle}), do: check({:update, conn, params, module, bundle})
  def handle({:delete, conn, params, module, bundle}), do: check({:delete, conn, params, module, bundle})
  def handle({:show, conn, params, module, bundle}), do: check({:show, conn, params, module, bundle})


  use Resources.ModelAuthorizor
end

defmodule Resources.Monitor.After do

  ##
  # when a monitor has been created, trigger an event for the MonitorConsumer
  # to go grab the manifest and parse it

  def handle({:create, conn, status, monitor, module}) do
    GenServer.cast(:monitor_consumer, {:create, monitor})
    {:create, conn, status, monitor, module}
  end
  def handle(res) do
    res
  end
end




defmodule Resources.Monitor do
  import Ecto.Query
  alias Models.Monitor
  alias Models.PackageMonitor
  alias Models.Package
  alias Models.User


  use Finch.Resource, [
    before: [
      Resources.Monitor.Authenticator,
      Resources.Monitor.Authorizor,
      Resources.Monitor.Validator
    ],
    after: [
      Resources.Monitor.After
    ]
  ]

  def model, do: Monitor
  def repo, do: Repo
  def page_size, do: 100


  def handle({:show, conn, params, module, bundle}) do
    id = get_id(params)
    result = (from m in model,
      where: m.id == ^id, 
      select: m) 
      |> Repo.all 
      |> List.first 
      |> to_serializable

    packages = (from pm in PackageMonitor,
      join: p in Package, on: pm.package_id == p.id,
      where: pm.monitor_id == ^id,
      select: p)
      |> Repo.all
      |> Finch.Serializer.to_serializable(Package, [exclude: []])

    result = Dict.put(result, "packages", packages)
    {conn, ok, result}
  end

  def tap(q, :where, {:index, _, _, _, bundle}) do
    user_id = bundle[:user].id
    q |> where([m], m.user_id == ^user_id) 
  end

  def tap(q, clause, req), do: super(q, clause, req)
  def handle(req), do: super(req)



end