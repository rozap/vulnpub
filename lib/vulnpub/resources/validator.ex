defmodule Resources.ModelValidator do


  def check_type(:integer, name, value) when is_integer(value), do: {:ok, name, value}
  def check_type(:integer, name, value), do: {:error, name, "This needs to be an integer"}

  def check_type(:string, name, value) when is_bitstring(value), do: {:ok, name, value}
  def check_type(:string, name, value), do: {:error, name, "This needs to be a string"}

  def check_type(:float, name, value) when is_float(value), do: {:ok, name, value}
  def check_type(:float, name, value), do: {:error, name, "This needs to be a float"}

  def check_type(:binary, name, value) when is_binary(value), do: {:ok, name, value}
  def check_type(:binary, name, value), do: {:error, name, "This needs to be a binary"}

  def check_type(:boolean, name, value) when is_boolean(value), do: {:ok, name, value}
  def check_type(:boolean, name, value), do: {:error, name, "This needs to be a boolean"}

  def check_type({:array, _inner_type}, name, value) when is_list(value), do: {:ok, name, value}
  def check_type({:array, _inner_type}, name, value), do: {:error, name, "This needs to be an array"}

  ##TODO: make the time validation actually work. need to cover...
  #:datetime
  # :date
  # :time
  # :virtual
  def check_type(:datetime, name, value) when is_bitstring(value), do: {:ok, name, value}
  def check_type(:datetime, name, value), do: {:error, name, "This needs to be a datetime"}

  def check_type(_, name, value), do: {:ok, name, value}


  def make_error_message(errors) do
    {"errors", Enum.map(errors, fn {:error, name, value} -> {name, value} end)}
  end

  def validate(:create, conn, params, module) do
    field_types = module.model.field_types
    :io.format("FIELD TYPES ~p~n", [field_types])
    checked = Enum.map(field_types, fn {name, type} -> check_type(type, name, params[name]) end)
    errors = Enum.filter(checked, fn {status, _, _} -> status == :error end)
    if length(errors) > 0 do
      {:create, :bad_request, conn, make_error_message(errors)}
    else
      {:create, :ok, conn, params}
    end
  end

  def validate(:update, conn, params, module) do
    IO.puts("VALIDATE update")
  end

  def validate(:destroy, conn, params, module) do
    IO.puts("VALIDATE destroy")
  end

end