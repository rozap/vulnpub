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


      def ingest(atom_keylist) do
        types = Enum.map(__MODULE__.__schema__(:field_names), fn name -> {name, __MODULE__.__schema__(:field_type, name)} end)
        Enum.map(types, fn {name, type} -> {name, to_fieldtype(type, atom_keylist[name])} end)
      end

      def to_atom_keylist(params) do
        keylist = Dict.to_list(params)
        Enum.map(keylist, fn {key, val} -> {String.to_atom(key), val} end)
      end

      def allocate(params) do
        adapted = to_atom_keylist(params) |> ingest |> adapt
        struct(__MODULE__, adapted)
      end


    end
  end




end