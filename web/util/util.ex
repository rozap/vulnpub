defmodule Util do
    
  def now do
    Ecto.DateTime.from_erl(:erlang.localtime())
  end

end