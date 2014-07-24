

defmodule Test.UserTest do
  use ExUnit.Case
  use PlugHelper

  test "can create a user" do
    {conn, req_body} = simulate_json(Vulnpub.Router, :post, "api/v1/users", "test/json/new_user.json")
    {:ok, resp_body} = JSON.decode(conn.resp_body)
    assert Dict.get(req_body, "username") == Dict.get(resp_body, "username")
    assert Dict.get(req_body, "email") == Dict.get(resp_body, "email")
    assert Dict.get(resp_body, "id") != nil
  end

  test "can get a list of users" do
    conn = simulate_request(Vulnpub.Router, :get, "api/v1/users")
    {:ok, resp_body} = JSON.decode(conn.resp_body)
    assert length(resp_body) > 0
  end


end
