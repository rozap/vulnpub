defmodule Resources.UserAuthorizor do
  @verbs [:create, :show, :index, :destroy, :update]

  defmacro __using__(options) do
    only = Keyword.get(options, :only, @verbs)
    except = Keyword.get(options, :except, [])
    only = (only -- except)

    quote [unquote: false, bind_quoted: [only: only]]  do
      import Ecto.Query


      def user_id_attribute do
        throw :not_implemented
      end

      def model do
        throw :not_implemented
      end

      def check({verb, conn, params, module, bundle}) do
        try do
          user_id = bundle[:user].id
          id = String.to_integer params[:id]
          [monitor] = (from m in model, 
            where: field(m, ^user_id_attribute) == ^user_id and m.id == ^id, 
            select: m) 
          |> Repo.all
          {verb, conn, params, module, bundle}
        rescue
          _ -> throw {:unauthorized, %{error: "You are not authorized to do that"}}
        end
      end

      for verb <- only do
        def handle({unquote(verb), conn, params, module, bundle}) do 
          check({unquote(verb), conn, params, module, bundle})
        end
      end

      def handle({verb, conn, params, module, bundle}) do
        {verb, conn, params, module, bundle}
      end


      defoverridable [user_id_attribute: 0,  model: 0]
    end



  end
end