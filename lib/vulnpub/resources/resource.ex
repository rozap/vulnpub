defmodule Resources.Resource do
  use Phoenix.Controller

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
     
      @bad_request 400
      @unauthorized 401
      @created 201
      @accepted 202
     
      import Ecto.Query, only: [from: 2]


      def get_id(params) do
        String.to_integer(params["id"])
      end







      def dispatch(verb, conn, params) do
        middleware = unquote(all_opts[:middleware])
        try do
          Enum.map(middleware, fn layer -> layer.handle(verb, conn, params, __MODULE__) end)
          handle(verb, conn, params)
        catch
          {:bad_request, errors} -> json conn, @bad_request, raw(errors)
          {:unauthorized, errors} -> json conn, @unauthorized, raw(errors)
        end
      end

      def index(conn, params), do: dispatch(:index, conn, params)
      def show(conn, params), do: dispatch(:show, conn, params)
      def create(conn, params), do: dispatch(:create, conn, params)
      def update(conn, params), do: dispatch(:update, conn, params)
      def destroy(conn, params), do: dispatch(:destroy, conn, params)


      def handle(:index, conn, params) do
        query = from u in model, select: u
        result = Repo.all(query)
        json conn, serialize(result)
      end

      def handle(:create, conn, params) do
        thing = model.allocate(params) |> Repo.insert
        json conn, @created, serialize(thing)
      end

      def handle(:show, conn, params) do
        id = get_id(params)
        query = from u in model, where: u.id == ^id, select: u
        [result] = Repo.all(query)
        json conn, serialize(result)
      end

      def handle(:update, conn, params) do
        id = get_id(params)
        row = model.allocate(params)
        :ok = Ecto.Model.put_primary_key(row, id) |> Repo.update
        json conn, @accepted, serialize(row)
      end

      def handle(:destroy, conn, params) do
        id = get_id(params)
        query = from u in model, where: u.id == ^id, select: u
        [row] = Repo.all(query)
        Repo.delete(row)
        json conn, @accepted, serialize(row)
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
