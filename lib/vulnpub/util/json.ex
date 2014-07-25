defimpl JSON.Encode, for: Ecto.DateTime do
  def to_json(%Ecto.DateTime{year: year, month: month, day: day, hour: hour, min: min, sec: sec}) do
    {:ok, "\"#{day}/#{month}/#{year} #{hour}:#{min}:#{sec}\""}
  end

  def typeof(_), do: :datetime
end






