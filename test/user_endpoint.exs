

defmodule Test.UserTest do
  use ExUnit.Case
  use PlugHelper

  test "can create a user" do
    {conn, req_body} = simulate_json(Vulnpub.Router, :post, "api/v1/users", "test/json/new_user.json")
    {:ok, resp_body} = JSON.decode(conn.resp_body)
    assert Dict.get(req_body, "username") == Dict.get(resp_body, "username")
    assert Dict.get(req_body, "email") == Dict.get(resp_body, "email")
    assert Dict.get(resp_body, "id") != nil
    assert conn.status == 201
  end

  test "cannot create a user that is missing fields" do
    {conn, req_body} = simulate_json(Vulnpub.Router, :post, "api/v1/users", "test/json/invalid_new_user.json")
    {:ok, resp_body} = JSON.decode(conn.resp_body)
    [root, error_dict] = resp_body
    assert root == "errors"
    assert Dict.get(error_dict, "password") == "This needs to be a string"
    assert Dict.get(error_dict, "username") == "This needs to be a string"
    assert conn.status == 400

  end

  test "cannot create a user that is missing fields" do
    {conn, req_body} = simulate_json(Vulnpub.Router, :post, "api/v1/users", "test/json/invalid_new_user_1.json")
    {:ok, resp_body} = JSON.decode(conn.resp_body)
    [root, error_dict] = resp_body
    assert root == "errors"
    assert Dict.get(error_dict, "password") == "This needs to be a string"
    assert Dict.get(error_dict, "username") == "This needs to be a string"
    assert conn.status == 400
  end


  test "can get a list of users" do
    conn = simulate_request(Vulnpub.Router, :get, "api/v1/users")
    {:ok, resp_body} = JSON.decode(conn.resp_body)
    assert length(resp_body) > 0
    assert conn.status == 200
  end


end
