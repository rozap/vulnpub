defmodule Vulnpub.Model do



  
  defmacro __using__(_opts) do
    quote do
      def adapt(atom_keylist) do
        atom_keylist
      end

      defp to_fieldtype(_, nil), do: nil

      defp to_fieldtype(:datetime, string_value) do
        [date, time] = String.split(string_value, " ")
        [day, month, year] = Enum.map(String.split(date, "/"), &(String.to_integer &1))
        [hour, min, sec] = Enum.map(String.split(time, ":"), &(String.to_integer &1))
        %Ecto.DateTime{year: year, month: month, day: day, hour: hour, min: min, sec: sec}
      end

      defp to_fieldtype(_, value), do: value

      def field_types do
        Enum.map(__MODULE__.__schema__(:field_names), fn name -> {name, __MODULE__.__schema__(:field_type, name)} end)
      end

      def ingest(atom_keylist) do
        Enum.map(field_types, fn {name, type} -> {name, to_fieldtype(type, atom_keylist[name])} end)
      end

      def allocate(params) do
        adapted = Map.to_list(params) |> ingest |> adapt
        struct(__MODULE__, adapted)
      end

      def has_user? do
        :user in __MODULE__.__schema__(:associations)
      end

    end
  end




end