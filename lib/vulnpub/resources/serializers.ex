

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
    schema.__schema__(:keywords, model)
    |> Enum.filter(fn {key, val} -> not key in exclude end)
    |> Enum.into(%{})
  end

end


