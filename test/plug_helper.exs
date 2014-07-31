defmodule PlugHelper do

  defmacro __using__(_opts) do
    quote do
      use Plug.Test
      def simulate_request(router, http_method, path, params_or_body \\ nil) do
        conn = conn(http_method, path, params_or_body)
        conn = router.call(conn, [])
        {conn.status,  JSON.decode(conn.resp_body)}
      end


      def simulate_json_file(router, http_method, path, filename, headers \\ []) do
        body = File.read! filename
        headers = [{"content-type", "application/json"}] ++ headers
        conn = conn(http_method, path, body, [headers: headers])
        {:ok, req_body} = JSON.decode(body)
        conn = router.call(conn, [])
        {:ok, resp_body} = JSON.decode(conn.resp_body)
        {conn.status, req_body, resp_body}
      end


      def simulate_json(router, http_method, path, req_body \\ nil, headers \\ []) do
        headers = [{"content-type", "application/json"}] ++ headers
        conn = case req_body do
          nil -> conn(http_method, path, "{}", [headers: headers])
          _ -> 
            {:ok, json_body} = JSON.encode(req_body)
            conn(http_method, path, json_body, [headers: headers])
        end
        conn = router.call(conn, [])
        {:ok, resp_body} = JSON.decode(conn.resp_body)
        {conn.status, req_body, resp_body}
      end
    end
  end
end
