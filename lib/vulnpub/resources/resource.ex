defmodule Resources.Resource do
  use Phoenix.Controller

  def default_for(:exclude) do 
    []
  end

  def default_opts(options) do
    Enum.map(options, fn {key, val} -> if val == nil, do: {key, default_for(val)}, else: {key, val} end)
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


      def resp(thing) do
        Resources.Serializer.to_json(thing, model, unquote(all_opts))
      end
    end
  end
end
