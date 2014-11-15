defimpl Jazz.Encoder, for: Ecto.DateTime do

  def encode(%Ecto.DateTime{year: year, month: month, day: day, hour: hour, min: min, sec: sec}, opts \\ []) do
    "#{month}/#{day}/#{year} #{hour}:#{min}:#{sec}-05:00"
  end
  
end
