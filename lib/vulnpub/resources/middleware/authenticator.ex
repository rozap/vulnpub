defmodule Resources.Authenticator do

  defmacro __using__(options) do


    quote do
      import Ecto.Query, only: [from: 2]
      @verbs [:create, :show, :index, :destroy, :update]

      Enum.each @verbs, fn(verb) -> 
        :io.format("DEF HANDLE ~p", [verb])
        def handle({verb, conn, params, module, bundle}) do
          try do
            req_headers = Enum.map(conn.req_headers, fn {key, value} -> {String.to_atom(key), value} end)
            [username, key] = String.split(Keyword.fetch!(req_headers, :authentication), ":")
            [user] = (from a in Models.ApiKey, 
              where: a.key == ^key,
              inner_join: u in Models.User,
              on: u.id == a.user_id,
              select: u,
              where: u.username == ^username) |> Repo.all
            :io.format("user ~p~n", [user])
            {verb, conn, params, module, bundle}
          rescue
            _ -> throw {:forbidden, [error: "You need to be logged in to do that"]}
          end
        end



      end
    end
  end
end