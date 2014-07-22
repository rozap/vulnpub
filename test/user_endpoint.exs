

defmodule Test.DBTest do
  use ExUnit.Case
  use PlugHelper

  test "can create a user" do
    {conn, resp_body} = simulate_json(Vulnpub.Router, :post, "api/v1/users", "test/json/new_user.json")
    # resp_body = JSON.decode(conn.resp_body)
    # assert Dict.get(req_body, "username") == Dict.get(resp_body, "username")
    # assert Dict.get(req_body, "email") == Dict.get(resp_body, "email")
  end

  test "can get a list of users" do
    conn = simulate_request(Vulnpub.Router, :get, "api/v1/users")
    IO.puts(conn.resp_body)
  end


end
