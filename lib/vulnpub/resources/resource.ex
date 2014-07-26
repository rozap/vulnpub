defmodule Resources.Resource do
  use Phoenix.Controller

  defp opts, do: [:exclude, :id_attr, :validator]
  def default_for(:exclude), do: []
  def default_for(:id_attr), do: "id"
  def default_for(:validator), do: Resources.ModelValidator



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

      def validate(kind, conn, params) do
        unquote(all_opts[:validator]).validate(kind, conn, params, __MODULE__)
      end


      def handle({_, :bad_request, conn, msg}) do
        json conn, raw(msg)
      end

      def handle({:create, :ok, conn, params}) do
        thing = model.allocate(params) |> Repo.insert
        json conn, serialize(thing)
      end

      def index(conn, params) do
        query = from u in model, select: u
        result = Repo.all(query)
        json conn, serialize(result)
      end

      def create(conn, params) do
        validate(:create, conn, params) |> handle
      end

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
