defmodule Vulnpub.Model do
  
  defmacro __using__(_opts) do
    quote do
      def adapt(keylist) do
        :io.format("Keylist :((~n", [])
        keylist
      end

      def allocate(params) do
        keylist = Dict.to_list(params)
        atoms = Enum.map(keylist, fn {key, val} -> {String.to_atom(key), val} end)
        adapted = __MODULE__.adapt(atoms)
        struct(__MODULE__, atoms)
      end
    end
  end




end