defmodule Vulnpub.Model do
  
  defmacro __using__(_opts) do
    quote do
      def adapt(keylist) do
        keylist
      end

      def allocate(params) do
        keylist = Dict.to_list(params)
        atoms = Enum.map(keylist, fn {key, val} -> {String.to_atom(key), val} end)
        adapted = __MODULE__.adapt(atoms)
        struct(__MODULE__, adapted)
      end
    end
  end




end