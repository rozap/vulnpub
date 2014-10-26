

defmodule Resources.Reset do
  alias Models.Reset
  alias Models.User
  use Finch.Resource, [
    before: [
      Resources.Reset.Validator
    ]
  ]

  def id_field, do: :key
  def get_id(params), do: params[:id]
  def repo, do: Repo
  def model, do: Reset

  defmodule Validator do
    use Finch.Middleware.ModelValidator, [only: [:create]]
    def ignore_fields(_) do
      [:id, :created, :modified, :username, :key, :user_id]
    end

    def handle({:create, conn, params, module, bundle}) do
      %{username: username} = params
      query = from u in Models.User, where: u.username == ^username, select: u
      bundle = case Repo.all(query) do
        [] -> throw {:bad_request, %{:errors => %{:username => "The username \"#{username}\" doesn't exist"}}}
        [user] -> Dict.put(bundle, :user, user)
      end
      {:create, conn, params, module, bundle}
    end

    def handle({:update, conn, params, module, bundle}) do
      %{id: key, password: password} = params
      reset = (from r in Reset, where: r.key == ^key, select: r)
        |> Repo.all
      if length(reset) == 0 do
        throw {:bad_request, %{errors: %{key: "That reset key is invalid or has already been used"}}}
      end
      if String.length(password) < 8 do
        throw {:bad_request, %{errors: %{password: "This needs to be 8 or more characters"}}}
      end
      bundle = Dict.put(bundle, :reset, hd(reset))
      {:update, conn, params, module, bundle}
    end
  end



  def handle({:create, conn, params, module, bundle}) do
    props = %{user_id: bundle.user.id, key: Reset.gen_key}
    reset = Reset.allocate(props) |> Repo.insert
    GenServer.cast(:emailer, {:forgot, bundle.user, reset})
    {conn, created, %{status: "sent"}}
  end

  def handle({:update, conn, %{password: password} = params, module, bundle}) do
    user = Repo.get(User, bundle.reset.user_id)
    user = %{user | password: User.hash_password(password)}
    Repo.update(user)
    Repo.delete(bundle.reset)
    {conn, created, %{status: "updated"}}
  end


end