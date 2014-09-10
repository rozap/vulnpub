defimpl Jazz.Encoder, for: Ecto.DateTime do

  def encode(%Ecto.DateTime{year: year, month: month, day: day, hour: hour, min: min, sec: sec}, opts \\ []) do
    "#{day}/#{month}/#{year} #{hour}:#{min}:#{sec}"
  end
  
end
