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

      def index(conn, params) do
        query = from u in model, select: u
        result = Repo.all(query)
        json conn, resp(result)
      end

      def create(conn, params) do
        thing = model.allocate(params) |> Repo.insert
        json conn, resp(thing)
      end

      def show(conn, params) do

        :io.format("PARAMS ~p ~p~n", [unquote(all_opts), params[unquote(all_opts)[:id_attr]]])
        id = String.to_integer(params["id"])
        query = from u in model, where: u.id == ^id, select: u
        result = Repo.all(query)
        json conn, resp(result)
      end

      def update(conn, params) do

      end



      def destroy(conn, params) do
        json conn, {:something, "ok"}
      end


      def resp(thing) do
        Resources.Serializer.to_json(thing, model, unquote(all_opts))
      end
    end
  end
end
