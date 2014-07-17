

defimpl Serializer, for: Models.User do

  @exclude [:password]

  def to_serializable(model) do
    key_list = Models.User.__schema__(:keywords, model)
    Enum.filter(key_list, fn {key, val} -> not key in @exclude end)
  end
end