

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
    %{"errors" => errors} = resp_body
    %{"errors" => %{"password" => pw_msg, "username" => un_msg}} = resp_body
    assert pw_msg == "This needs to be a string"
    assert un_msg == "This needs to be a string"
    assert status == 400
  end

  test "cannot create a user that is missing fields" do
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/users", "test/json/invalid_new_user_1.json")
    %{"errors" => %{"password" => pw_msg, "username" => un_msg}} = resp_body
    assert pw_msg == "This needs to be a string"
    assert un_msg == "This needs to be a string"
    assert status == 400
  end


  test "can get a list of users when logged in" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    %{"key" => key} = apikey_resp
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/users", nil, [{"authentication", "foo:#{key}"}])
    %{"data" => data} = resp_body
    assert length(data) == 1
    assert status == 200
  end

  test "cannot get a list of users when not logged in" do
    DBHelpers.create_user()
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/users")
    assert status == 403
  end

  test "cannot have two users with the same name" do
    DBHelpers.create_user()
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/users", "test/json/new_user_0.json")
    assert status == 400
  end
end
