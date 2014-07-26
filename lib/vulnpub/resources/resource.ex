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

      import Ecto.Query, only: [from: 2]


      def get_id(params) do
        String.to_integer(params["id"])
      end

      def handle({_, :bad_request, conn, msg}) do
        json conn, raw(msg)
      end

      def handle(:create, conn, params) do
        thing = model.allocate(params) |> Repo.insert
        json conn, serialize(thing)
      end

      def index(conn, params) do
        query = from u in model, select: u
        result = Repo.all(query)
        json conn, serialize(result)
      end


      def dispatch({verb, conn, params}) do
        middleware = unquote(all_opts[:middleware])
        try do
          Enum.map(middleware, fn layer -> layer.handle(verb, conn, params, __MODULE__) end)
          handle(verb, conn, params)
        catch
          {:bad_request, errors} -> json conn, raw(errors)
        end
      end

      def create(conn, params), do: dispatch({:create, conn, params})

      def show(conn, params) do
        id = get_id(params)
        query = from u in model, where: u.id == ^id, select: u
        [result] = Repo.all(query)
        json conn, serialize(result)
      end

      def update(conn, params) do
        id = get_id(params)
        row = model.allocate(params)
        :ok = Ecto.Model.put_primary_key(row, id) |> Repo.update
        json conn, serialize(row)
      end



      def destroy(conn, params) do
        id = get_id(params)
        query = from u in model, where: u.id == ^id, select: u
        [row] = Repo.all(query)
        Repo.delete(row)
        json conn, serialize(row)
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
