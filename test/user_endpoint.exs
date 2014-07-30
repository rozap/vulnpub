

defmodule Test.UserTest do
  use ExUnit.Case
  use PlugHelper
  require DBHelpers

  setup do
    Fixture.load
    :ok
  end


  test "can create a user" do
    {status, req_body, resp_body} = DBHelpers.create_user
    assert Dict.get(req_body, "username") == Dict.get(resp_body, "username")
    assert Dict.get(req_body, "email") == Dict.get(resp_body, "email")
    assert Dict.get(resp_body, "id") != nil
    assert status == 201
    Dict.get(resp_body, "id")

  end

  test "cannot create a user that is missing fields" do
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/users", "test/json/invalid_new_user.json")
    [root, error_dict] = resp_body
    assert root == "errors"
    assert Dict.get(error_dict, "password") == "This needs to be a string"
    assert Dict.get(error_dict, "username") == "This needs to be a string"
    assert status == 400
  end

  test "cannot create a user that is missing fields" do
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/users", "test/json/invalid_new_user_1.json")
    [root, error_dict] = resp_body
    assert root == "errors"
    assert Dict.get(error_dict, "password") == "This needs to be a string"
    assert Dict.get(error_dict, "username") == "This needs to be a string"
    assert status == 400
  end


  test "can get a list of users when logged in" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/users", nil, [{"authentication", "foo:#{key}"}])
    assert length(resp_body) > 0
    assert status == 200
  end

  test "cannot get a list of users when not logged in" do
    DBHelpers.create_user()
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/users")
    assert status == 403
  end

  test "cannot have two users with the same name" do
    DBHelpers.create_user()
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/users", "test/json/new_user.json")
    assert status == 400
  end
end
