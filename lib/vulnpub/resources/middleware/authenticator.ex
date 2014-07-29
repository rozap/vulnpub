defmodule Resources.Authenticator do
  @verbs [:create, :show, :index, :destroy, :update]
  import Ecto.Query, only: [from: 2]


  def close({verb, conn, params, module, bundle}) do
    try do
      # :io.format("CHECKING ~p~n", [unquote(verb)])
      req_headers = Enum.map(conn.req_headers, fn {key, value} -> {String.to_atom(key), value} end)
      [username, key] = String.split(Keyword.fetch!(req_headers, :authentication), ":")
      [user] = (from a in Models.ApiKey, 
        where: a.key == ^key,
        inner_join: u in Models.User,
        on: u.id == a.user_id,
        select: u,
        where: u.username == ^username) |> Repo.all
      {:create, conn, params, module, bundle}
    rescue
      _ -> throw {:forbidden, [error: "You need to be logged in to do that"]}
    end
  end

  defmacro __using__(options) do
    open = Keyword.get(options, :open, [])
    closed = @verbs -- open

    quote [unquote: false, bind_quoted: [closed: closed]] do
      for verb <- closed do
        def handle({unquote(verb), conn, params, module, bundle}), do: Resources.Authenticator.close({unquote(verb), conn, params, module, bundle})
      end
      def handle({verb, conn, params, module, bundle}), do: {verb, conn, params, module, bundle}
    end
  end




end