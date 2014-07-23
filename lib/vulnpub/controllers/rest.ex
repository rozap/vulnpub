defmodule Controllers.Rest do
  
  defmacro __using__([model: model]) do
    quote do
      import Ecto.Query, only: [from: 2]

      def index(conn, params) do
        query = from u in unquote(model), select: u
        result = Repo.all(query)
        json conn, Resource.resp(result)
      end

      def create(conn, params) do
        user = unquote(model).allocate(params) |> Repo.insert
        json conn, Resource.resp(user)
      end          
    end
  end




end

