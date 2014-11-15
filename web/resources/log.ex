

defmodule Resources.Log do
  use Finch.Resource, []

  def model, do: raise :this_should_not_happen
  def repo, do: :this_should_not_happen

  def handle({:create, conn, params, module, bundle}) do
    params[:logs]
      |> Enum.map(
        fn [level | args] ->
          body = Enum.join(args, "\n")
          GenServer.cast(:stats_collector, {:insert, "client_#{level}", [value: body]})
        end)

    {conn, created, %{}}

  end 

end