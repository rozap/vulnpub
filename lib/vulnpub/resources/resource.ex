defmodule Resources.Resource do
  use Phoenix.Controller

  defp opts, do: [:exclude, :id_attr]
  def default_for(:exclude), do: []
  def default_for(:id_attr), do: "id"



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

      def index(conn, params) do
        query = from u in model, select: u
        result = Repo.all(query)
        json conn, serialize(result)
      end

      def create(conn, params) do
        thing = model.allocate(params) |> Repo.insert
        json conn, serialize(thing)
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
        JSON.encode(thing)
      end
    end
  end
end
