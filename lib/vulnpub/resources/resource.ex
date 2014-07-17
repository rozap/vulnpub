defprotocol Resource do
  @fallback_to_any true
  def to_json(_)
  def resp(_)
  def from_json(_)
end


defprotocol Serializer do
  @fallback_to_any true
  def to_serializable(_)
end



defimpl Resource, for: List do
  def to_json(results) do
    {:ok, json} = JSON.encode Enum.map(results, fn x -> Serializer.to_serializable(x) end)
    json
  end

  def resp(result) do
    Serializer.to_serializable(result)
      |> Resource.to_json
  end
end


defimpl Serializer, for: List do
  def to_serializable(items) do
    items
  end
end


defimpl Resource, for: Any do
  def to_json(serializable) do
    {:ok, json} = JSON.encode(serializable)
    json
  end

  def resp(model) do
    Serializer.to_serializable(model)
      |> Resource.to_json
  end
end


defimpl Serializer, for: Any do
  def to_serializable(model) do
    model
  end
end