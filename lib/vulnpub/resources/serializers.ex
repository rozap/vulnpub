

defprotocol Resources.Serializer do
  @fallback_to_any true
  def to_serializable(data, _, _)
end




defimpl Resources.Serializer, for: List do

  def to_serializable(items, schema, options) do
    Enum.map(items, fn x -> Resources.Serializer.to_serializable(x, schema, options) end)
  end
end


defimpl Resources.Serializer, for: Any do

  def to_serializable(nil, _, _), do: nil

  def to_serializable(model, schema, options) do
    exclude = options[:exclude]
    base = schema.__schema__(:keywords, model)
      |> Enum.filter(fn {key, val} -> not key in exclude end)
      |> Enum.into(%{})

    related = schema.__schema__(:associations)
      |> Enum.map(&({&1, schema.__schema__(:association, &1)}))
      |> Enum.map(
        fn {field_name, related_schema} ->
          case  Map.get(model, field_name) do
            nil -> nil
            {_, related_model} -> 
              case related_model.loaded do
                :ECTO_NOT_LOADED -> nil
                loaded -> {field_name, to_serializable(loaded, related_schema.associated, options)}
              end              
          end
        end)
      |> Enum.filter(&(not nil? &1))
      |> Enum.into(%{})
    Enum.into(base, related)
  end

end


