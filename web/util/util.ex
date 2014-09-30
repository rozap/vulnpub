defmodule Util do
    
  def now do
    Ecto.DateTime.from_erl(:erlang.localtime())
  end

  def past(deltas) do
    t = Map.to_list(now)
      |> Keyword.delete(:__struct__)
      |> Enum.map(fn {unit, value} ->
        {unit, value - Keyword.get(deltas, unit, 0)}
        end)

    %Ecto.DateTime{
      year: t[:year],
      month: t[:month],
      day: t[:day],
      hour: t[:hour],
      min: t[:min],
      sec: t[:sec]
    }

  end

end