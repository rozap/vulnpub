

defprotocol Resources.Serializer do
  @fallback_to_any true
  def to_json(data, _, _)
  def to_serializable(data, _, _)
end




defimpl Resources.Serializer, for: List do
  def to_json(data, schema, options) do
    {:ok, json} = JSON.encode Enum.map(data, fn x -> Resources.Serializer.to_serializable(x, schema, options) end)
    json
  end

  def to_serializable(items, schema, options) do
    items
  end
end


defimpl Resources.Serializer, for: Any do
  def to_json(data, schema, options) do
    serializable = to_serializable(data, schema, options)
    {:ok, json} = JSON.encode(serializable)
    json
  end

  def to_serializable(model, schema, options) do
    key_list = schema.__schema__(:keywords, model)
    Enum.filter(key_list, fn {key, val} -> not key in options[:exclude] end)
  end

end


