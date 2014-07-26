defmodule PlugHelper do

  defmacro __using__(_opts) do
    quote do
      use Plug.Test
      def simulate_request(router, http_method, path, params_or_body \\ nil) do
        conn = conn(http_method, path, params_or_body)
        router.call(conn, [])
      end


      def simulate_json_file(router, http_method, path, filename) do
        body = File.read! filename
        headers = [{"content-type", "application/json"}]
        conn = conn(http_method, path, body, headers: headers)
        {:ok, req_body} = JSON.decode(body)
        conn = router.call(conn, [])
        {:ok, resp_body} = JSON.decode(conn.resp_body)
        {conn.status, req_body, resp_body}
      end


      def simulate_json(router, http_method, path) do
        headers = [{"content-type", "application/json"}]
        conn = conn(http_method, path, headers: headers)
        conn = router.call(conn, [])
        {:ok, resp_body} = JSON.decode(conn.resp_body)
        {conn.status, resp_body}
      end

      def simulate_json(router, http_method, path, req_body) do
        headers = [{"content-type", "application/json"}]
        conn = conn(http_method, path, JSON.encode(req_body), headers: headers)
        conn = router.call(conn, [])
        {:ok, resp_body} = JSON.decode(conn.resp_body)
        {conn.status, req_body, resp_body}
      end
    end
  end
end
