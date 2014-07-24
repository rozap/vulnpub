defmodule Controllers.Rest do
  
  defmacro __using__([resources: resource]) do
    quote do
      import Ecto.Query, only: [from: 2]

      def index(conn, params) do
        IO.puts("INDEX OF THING")
        query = from u in unquote(resource).model, select: u
        result = Repo.all(query)
        json conn, unquote(resource).resp(result)
      end

      def create(conn, params) do
        thing = unquote(resource).model.allocate(params) |> Repo.insert
        json conn, unquote(resource).resp(thing)
      end          
    end
  end




end

