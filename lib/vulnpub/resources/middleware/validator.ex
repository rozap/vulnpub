defmodule Resources.ModelValidator do

  defmacro __using__(_) do
  
    quote do 

      def validate_type(:integer, name, value) when is_integer(value), do: {:ok, name, value}
      def validate_type(:integer, name, _), do: {:error, name, "This needs to be an integer"}

      def validate_type(:string, name, value) when is_bitstring(value), do: {:ok, name, value}
      def validate_type(:string, name, _), do: {:error, name, "This needs to be a string"}

      def validate_type(:float, name, value) when is_float(value), do: {:ok, name, value}
      def validate_type(:float, name, _), do: {:error, name, "This needs to be a float"}

      def validate_type(:binary, name, value) when is_binary(value), do: {:ok, name, value}
      def validate_type(:binary, name, _), do: {:error, name, "This needs to be a binary"}

      def validate_type(:boolean, name, value) when is_boolean(value), do: {:ok, name, value}
      def validate_type(:boolean, name, _), do: {:error, name, "This needs to be a boolean"}

      def validate_type({:array, _inner_type}, name, value) when is_list(value), do: {:ok, name, value}
      def validate_type({:array, _inner_type}, name, _), do: {:error, name, "This needs to be an array"}

      ##TODO: make the time validation actually work. need to cover...
      #:datetime
      # :date
      # :time
      # :virtual
      def validate_type(:datetime, name, value) when is_bitstring(value), do: {:ok, name, value}
      def validate_type(:datetime, name, value), do: {:error, name, "This needs to be a datetime"}

      def validate_type(_, name, value), do: {:ok, name, value}

      ###
      # By default, all fields just work. override this for specific stuff tho
      def validate_field(_, _, _), do: :ok


      def ignore_fields(:create), do: [:id, :created, :modified]
      def ignore_fields(_), do: [:created, :modified]


      def make_error_message(errors) do
        {"errors", Enum.map(errors, fn {:error, name, value} -> {name, value} end)}
      end


      defp params_to_check(verb, params, field_types, module) do
        included = Enum.filter(field_types, fn {name, _} -> not name in ignore_fields(verb) end) 
        Enum.map(included, fn {name, _type} -> {name, Dict.get(params, Atom.to_string(name))} end)
      end

      def validate(verb, conn, params, module) do
        field_types = module.model.field_types
        check_params = params_to_check(verb, params, field_types, module)
        # :io.format("PARAMS ~p ~n CHECK PARAMS ~p~n", [params, check_params])
        checked = Enum.map(check_params, fn {name, value} -> validate_type(Keyword.fetch!(field_types, name), name, value) end)
        errors = Enum.filter(checked, fn {status, _, _} -> status == :error end)
        if length(errors) > 0, do: throw {:bad_request,  make_error_message(errors)}
        Enum.map(check_params, fn {name, value} -> validate_field(verb, name, value) end)
        :ok
      end


      def handle(:create, conn, params, module), do: validate(:create, conn, params, module)
      def handle(:update, conn, params, module), do: validate(:update, conn, params, module)
      def handle(_, conn, params, module), do: :ok

    end
  end

  

end