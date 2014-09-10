defmodule Resources.Resource do
  import Phoenix.Controller

  defp opts, do: [:exclude, :middleware, :triggers]
  def default_for(:exclude), do: []

  def default_for(:middleware), do: []
  def default_for(:triggers), do: []



  def default_opts(options) do
    Enum.map(opts, fn key -> if options[key] == nil, do: {key, default_for(key)}, else: {key, options[key]} end)
  end



  defmacro __using__(options) do
    all_opts = Resources.Resource.default_opts(options)

    quote do
      use Phoenix.Controller, unquote(all_opts)
      require Jazz
      use Jazz

      def bad_request, do: 400
      def unauthorized, do: 401
      def forbidden, do: 403
      def created, do: 201
      def accepted, do: 202
      def ok, do: 200
     
      import Ecto.Query


      def id_field, do: :id
      def get_id(params), do: String.to_integer(params[id_field])

      def page_size, do: 40


      def dispatch(verb, conn, params) do
        middleware = unquote(all_opts[:middleware])
        triggers = unquote(all_opts[:triggers])
        #convert the string => val map to atom => val map
        params =  Enum.into(Enum.map(params, fn {key, value} -> {String.to_atom(key), value} end), Map.new)
        try do
          request = {verb, conn, params, __MODULE__, %{}}
          request = Enum.reduce(middleware, request, fn(layer, req) -> layer.handle(req) end)
          response = handle request
          {verb, conn, status, entity} = Enum.reduce(triggers, Tuple.insert_at(response, 0, verb), fn(layer, res) -> layer.handle(res) end)
          json conn, status, serialize(entity)
        catch
          {:bad_request, errors} -> json conn, bad_request, serialize(errors)
          {:unauthorized, errors} -> json conn, unauthorized, serialize(errors)
          {:forbidden, errors} -> json conn, forbidden, serialize(errors)
        end
      end

      def index(conn, params), do: dispatch(:index, conn, params)
      def show(conn, params), do: dispatch(:show, conn, params)
      def create(conn, params), do: dispatch(:create, conn, params)
      def update(conn, params), do: dispatch(:update, conn, params)
      def destroy(conn, params), do: dispatch(:destroy, conn, params)





      def tap(q, :where, {:show, _, params, _, _}) do
        id = get_id(params)
        :io.format("GET ID ~p ~p ~p ~n", [id_field, id, params])
        q |> where([i], field(i, ^id_field) == ^id)
      end

      def tap(q, :where, _), do: q
      def tap(q, :select, _), do: q |> select([i], i)

      def query(request) do
        model |> tap(:where, request) |> tap(:select, request)
      end


      ##
      # return a count query
      def index_size(request) do
        model
          |> tap(:where, request) 
          |> select([i], count(i.id))
          |> Repo.all
      end


      ##
      # get the actual size (int) of the index
      defp index_count(request) do
        case index_size(request) do
          [] -> 0
          [num] -> num
        end
      end


      def handle({:index, conn, params, module, bundle}) do
        request = {:index, conn, params, module, bundle}
        offset = (Dict.get(params, :page, "0") |> String.to_integer) * page_size
        filter = Dict.get(params, :filter, false)
        order = Dict.get(params, :order, false)

        expr = query request
        if filter do
          [fname, value] = String.split(filter, ":")
          fname = String.to_atom fname
          value = "%" <> value <> "%"
          expr = expr |> where([u], ilike(field(u, ^fname), ^value))
        end

        if order do
          #implement backwards ordering too...
          order = String.to_atom order
          expr = expr |> order_by([u], desc: field(u, ^order))
        end

        data = expr
          |> limit(page_size)
          |> offset(offset)
          |> Repo.all 
          |> to_serializable

        count = index_count(request)
        pages = trunc(count / page_size)
        result = %{:meta => %{
          :pages => pages, 
          :count => count, 
          :next => trunc((page_size + offset) / page_size)
        }, :data => data}
        {conn, ok, result}
      end

      def handle({:create, conn, params, module, bundle}) do
        if model.has_user? and Dict.get(bundle, :user, false) do
          params = Dict.put(params, :user_id, bundle[:user].id)
        end
        thing = model.allocate(params) |> Repo.insert |> to_serializable
        {conn, created, thing}
      end

      def handle({:show, conn, params, module, bundle}) do
        result = model
          |> tap(:where, {:show, conn, params, module, bundle})
          |> tap(:select, {:show, conn, params, module, bundle})
          |> Repo.all 
          |> List.first
          |> to_serializable
        {conn, ok, result}
      end

      def handle({:update, conn, params, module, bundle}) do
        id = get_id(params)
        row = model.allocate(params)
        :ok = Ecto.Model.put_primary_key(row, id) |> Repo.update
        {conn, accepted, to_serializable(row)}
      end

      def handle({:destroy, conn, params, module, bundle}) do
        id = get_id(params)
        result = model
          |> tap(:where, {:show, conn, params, module, bundle})
          |> tap(:select, {:show, conn, params, module, bundle})
          |> Repo.all
          |> List.first


        Repo.delete(result)
        {conn, accepted, to_serializable(result)}
      end

      def to_serializable(thing) do
        Resources.Serializer.to_serializable(thing, model, unquote(all_opts))
      end

      def serialize(thing) do
        Jazz.encode!(thing)
      end
    end
  end
end
