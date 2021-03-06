
defmodule Resources.Monitor.Validator do
  use Finch.Middleware.ModelValidator, [only: [:create, :update]]
  def ignore_fields(_), do: [:id, :created, :modified, :user_id, :last_polled, :status]
end


defmodule Resources.Monitor.Authenticator do
  use Resources.Authenticator, []
end


defmodule Resources.Monitor.Authorizor do
  use Resources.UserAuthorizor, [only: [:update, :delete, :show]]
  
  def model, do: Models.Monitor
  def user_id_attribute, do: :user_id
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
  def page_size, do: 99


  defp apply_package_filter(expr, params) do
    if params[:filter] do 
      String.split(params.filter, ",")
        |> Enum.map(fn(pair) -> String.split(pair, ":") end)
        |> Enum.map(fn([col, value]) -> {String.split(col, "."), value} end)
        |> Enum.filter(fn({toks, value}) -> hd(toks) == "package" end)
        |> Enum.reduce(expr, fn({toks, value}, x) ->
            value = "%#{value}%"
            col = String.to_atom(Enum.join(tl(toks), "."))
            x |> where([pm, p], ilike(field(p, ^col), ^value))
          end)
    else
      expr
    end
  end



  def handle({:show, conn, params, module, bundle}) do
    id = get_id(params)
    result = (from m in model,
      where: m.id == ^id, 
      select: m) 
      |> Repo.all 
      |> List.first 
      |> to_serializable


    offset = (Dict.get(params, :page, "0") |> String.to_integer) * page_size

    package_expr = PackageMonitor
      |> where([pm], pm.monitor_id == ^id)
      |> join(:left, [pm], p in pm.package, pm.package_id == p.id)
      |> apply_package_filter(params)

    packages = package_expr
      |> apply_order(params)
      |> limit(page_size)
      |> offset(offset)
      |> select([pm, p], p)
      |> Repo.all
      |> Finch.Serializer.to_serializable(Package, [exclude: []])


    [package_count] = package_expr 
      |> select([pm, p], count(p.id)) 
      |> Repo.all
    IO.inspect package_count
    pages = trunc(package_count / page_size)

    package_attr = %{:meta => %{
          :pages => pages, 
          :count => package_count, 
          :next => trunc((page_size + offset) / page_size)
        }, :data => packages}

    result = Dict.put(result, "packages", package_attr)
    {conn, ok, result}
  end

  def tap(q, :where, {:index, _, _, _, bundle}) do
    user_id = bundle[:user].id
    q |> where([m], m.user_id == ^user_id) 
  end

  def tap(q, clause, req), do: super(q, clause, req)
  def handle(req), do: super(req)



end