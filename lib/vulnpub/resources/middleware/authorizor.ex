defmodule Resources.ModelAuthorizor do
  def handle({verb, conn, params, module, bundle}), do: {verb, conn, params, module, bundle}
end