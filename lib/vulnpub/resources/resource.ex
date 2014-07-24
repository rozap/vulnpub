defmodule Resources.Resource do

  def default_for(:exclude) do 
    []
  end

  def default_opts(options) do
    Enum.map(options, fn {key, val} -> if val == nil, do: {key, default_for(val)}, else: {key, val} end)
  end


  defmacro __using__(options) do
    all_opts = Resources.Resource.default_opts(options)

    quote do
      def resp(thing) do
        :io.format("making resp for thing: ~p ~n", [thing])
        Resources.Serializer.to_json(thing, model, unquote(all_opts))
      end
    end
  end



end
