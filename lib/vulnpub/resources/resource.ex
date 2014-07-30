defmodule Resources.Resource do
  import Phoenix.Controller

  defp opts, do: [:exclude, :id_attr, :middleware]
  def default_for(:exclude), do: []
  def default_for(:id_attr), do: "id"

  def default_for(:middleware), do: []






  def default_opts(options) do
    Enum.map(opts, fn key -> if options[key] == nil, do: {key, default_for(key)}, else: {key, options[key]} end)
  end



  defmacro __using__(options) do
    all_opts = Resources.Resource.default_opts(options)

    quote do
      use Phoenix.Controller

      def bad_request, do: 400
      def unauthorized, do: 401
      def forbidden, do: 403
      def created, do: 201
      def accepted, do: 202
     
      import Ecto.Query, only: [from: 2]


      def get_id(params) do
        String.to_integer(params["id"])
      end


      def dispatch(verb, conn, params) do
        middleware = unquote(all_opts[:middleware])
        #convert the string => val map to atom => val map
        params =  Enum.into(Enum.map(params, fn {key, value} -> {String.to_atom(key), value} end), Map.new)
        try do
          acc = {verb, conn, params, __MODULE__, %{}}
          Enum.reduce(middleware, acc, fn(layer, acc) -> layer.handle(acc) end) |> handle
        catch
          {:bad_request, errors} -> json conn, bad_request, raw(errors)
          {:unauthorized, errors} -> json conn, unauthorized, raw(errors)
          {:forbidden, errors} -> json conn, forbidden, raw(errors)
        end
      end

      def index(conn, params), do: dispatch(:index, conn, params)
      def show(conn, params), do: dispatch(:show, conn, params)
      def create(conn, params), do: dispatch(:create, conn, params)
      def update(conn, params), do: dispatch(:update, conn, params)
      def destroy(conn, params), do: dispatch(:destroy, conn, params)


      def handle({:index, conn, params, module, bundle}) do
        query = from u in model, select: u
        result = Repo.all(query)
        json conn, serialize(result)
      end

      def handle({:create, conn, params, module, bundle}) do
        thing = model.allocate(params) |> Repo.insert
        json conn, created, serialize(thing)
      end

      def handle({:show, conn, params, module, bundle}) do
        id = get_id(params)
        query = from u in model, where: u.id == ^id, select: u
        result = Repo.get(query)
        json conn, serialize(result)
      end

      def handle({:update, conn, params, module, bundle}) do
        id = get_id(params)
        row = model.allocate(params)
        :ok = Ecto.Model.put_primary_key(row, id) |> Repo.update
        json conn, accepted, serialize(row)
      end

      def handle({:destroy, conn, params, module, bundle}) do
        id = get_id(params)
        query = from u in model, where: u.id == ^id, select: u
        [row] = Repo.all(query)
        Repo.delete(row)
        json conn, accepted, serialize(row)
      end


      def serialize(thing) do
        Resources.Serializer.to_json(thing, model, unquote(all_opts))
      end

      def raw(thing) do
        {:ok, json} = JSON.encode(thing)
        json
      end
    end
  end
end
