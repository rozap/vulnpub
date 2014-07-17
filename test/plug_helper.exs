defmodule PlugHelper do

  defmacro __using__(_opts) do
    quote do
      use Plug.Test
      def simulate_request(router, http_method, path, params_or_body \\ nil) do
        conn = conn(http_method, path, params_or_body)
        router.call(conn, [])
      end


      def simulate_json(router, http_method, path, filename) do
        body = File.read! filename
        headers = [{"content-type", "application/json"}]
        conn = conn(http_method, path, body, headers: headers)
        {:ok, decoded} = JSON.decode(body)
        {router.call(conn, []), decoded}
      end
    end
  end
end
