
defmodule Resources.Monitor.Validator do
  def ignore_fields(_), do: [:id, :created, :modified, :user_id]
  use Resources.ModelValidator, [only: [:create, :update]]
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

defmodule Resources.Monitor.Trigger do

  ##
  # when a monitor has been created, trigger an event for the MonitorConsumer
  # to go grab the manifest and parse it
  def handle({:create, conn, status, monitor}) do
    GenServer.cast(:monitor_consumer, {:create, monitor})
    {:create, conn, status, monitor}
  end
  def handle(res), do: res
end




defmodule Resources.Monitor do
  require Resources.Resource
  import Ecto.Query
  alias Models.Monitor
  alias Models.PackageMonitor
  alias Models.Package
  alias Models.User


  def model, do: Monitor
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
      |> Resources.Serializer.to_serializable(Package, [exclude: []])

    result = Dict.put(result, "packages", packages)
    {conn, ok, result}
  end


  def tap(data, {:index, conn, params, module, bundle}) do
    user_id = bundle[:user].id
    data |> where([m], m.user_id == ^user_id)
  end




	use Resources.Resource, [
    exclude: [], 
    middleware: [
      Resources.Monitor.Authenticator,
      Resources.Monitor.Authorizor,
      Resources.Monitor.Validator
    ],
    triggers: [
      Resources.Monitor.Trigger
    ]
  ]
end