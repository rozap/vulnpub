
defmodule Resources.ApiKey.Validator do
  import Ecto.Query, only: [from: 2]
  use Finch.Middleware.ModelValidator, [only: [:create]]

  def validate_together(:create, params, bundle) do
    %{:username => username, :password => password} = params
    bundle = case (from u in Models.User, where: u.username == ^username, select: u) |> Repo.all do
      [] -> throw {:bad_request, 
        %{:errors => %{:username => "The username is invalid"}}
      }
      [user] ->
        {:ok, provided_hash} = hashed = :bcrypt.hashpw(password, user.password)
        if List.to_string(provided_hash) != user.password do
          raise throw {:bad_request, 
            %{:errors => %{:username => "The username/password combination is invalid"}}
          }
        end
        Dict.put(bundle, :user, user)
    end
    {params, bundle}
  end

  def validate_together(verb, params, bundle), do: super(verb, params, bundle)

  def ignore_fields(:create), do: [:key, :user_id, :id, :created, :modified]

end


defmodule Resources.ApiKey.Authenticator do
  use Resources.Authenticator, [only: [:index, :destroy, :show]]
end

defmodule Resources.ApiKey.Authorizor do
  import Ecto.Query

  def is_owner({verb, conn, params, module, bundle}) do
    try do
      user_id = bundle[:user].id
      key = params[:id]
      [monitor] = (from a in Models.ApiKey, 
        where: a.user_id == ^user_id and a.key == ^key, 
        select: a) 
        |> Repo.all
      {verb, conn, params, module, bundle}
    rescue
      _ -> throw {:unauthorized, %{error: "You are not authorized to do that"}}
    end
  end

  def handle(req = {:destroy, conn, params, module, bundle}), do: is_owner(req)
  def handle(req), do: req

  

end


defmodule Resources.ApiKey do
  import Phoenix.Controller
  import Ecto.Query

  use Finch.Resource, [
    before: [
        Resources.ApiKey.Authenticator,
        Resources.ApiKey.Authorizor,
        Resources.ApiKey.Validator
    ]
  ]


  def id_field, do: :key
  def get_id(params), do: params[:id]
  def repo, do: Repo
  def model, do: Models.ApiKey
  
  def tap(q, :where, {:index, _, _, _, bundle}) do
    user_id = bundle[:user].id
    q |> where([a], a.user_id == ^user_id) 
  end
  def tap(q, clause, req), do: super(q, clause, req)


  def handle({:create, conn, params, module, bundle}) do
    props = %{user_id: bundle.user.id, key: Models.ApiKey.gen_key, web: params[:web]}
    key = Models.ApiKey.allocate(props) |> Repo.insert |> to_serializable
    {conn, created, key}
  end

  def handle(req), do: super(req)




  
end