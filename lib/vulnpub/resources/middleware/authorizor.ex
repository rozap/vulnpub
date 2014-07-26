defmodule Resources.ModelAuthorizor do


  def authorize(:read, conn, params, module) do
    IO.puts("is authorized")
    :ok
  end


  def authorize(:write, conn, params, module) do
    IO.puts("is authorized")
    :ok
  end


  def handle(:create, conn, params, module), do: authorize(:write, conn, params, module)
  def handle(:update, conn, params, module), do: authorize(:write, conn, params, module)
  def handle(:destroy, conn, params, module), do: authorize(:write, conn, params, module)
  def handle(_, conn, params, module), do: authorize(:read, conn, params, module)

end