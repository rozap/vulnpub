

defmodule Test.UserTest do
  use ExUnit.Case
  use PlugHelper
  require DBHelpers

  setup do
    :timer.sleep(200)  #packages are checked async, so wait a lil bit
    Fixture.load

    :ok
  end


  test "can create a user" do
    {status, req_body, resp_body} = DBHelpers.create_user
    assert Dict.get(req_body, "username") == Dict.get(resp_body, "username")
    assert Dict.get(req_body, "email") == Dict.get(resp_body, "email")
    assert Dict.get(resp_body, "id") != nil
    assert status == 201
  end

  test "cannot create a user that is missing fields" do
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/users", "test/json/invalid_new_user.json")
    %{"errors" => errors} = resp_body
    %{"errors" => %{"password" => pw_msg, "username" => un_msg}} = resp_body
    assert pw_msg == "This needs to be a string"
    assert un_msg == "This needs to be a string"
    assert status == 400
  end

  test "can update your email" do
    {_, _, resp} = DBHelpers.create_apikey
    IO.inspect resp
    %{"key" => key, "user_id" => id} = resp
    headers = [{"authentication", "foo:#{key}"}]
    {status, _, resp} = simulate_json_file(Vulnpub.Router, :put, "api/v1/users/#{id}", "test/json/update_user.json", headers)
    assert resp["email"] == "new_email"
  end

  test "can update your password" do
    {_, _, resp} = DBHelpers.create_apikey
    %{"key" => key, "user_id" => id} = resp
    headers = [{"authentication", "foo:#{key}"}]
    {status, _, resp} = simulate_json_file(Vulnpub.Router, :put, "api/v1/users/#{id}", "test/json/update_user_1.json", headers)
    IO.inspect resp
    assert status == 202
    {status, _, resp} = simulate_json_file(Vulnpub.Router, :post, "api/v1/apikey", "test/json/new_apikey_2.json")
    IO.inspect resp
    assert status == 201
    assert resp["key"] != nil
  end

  test "cannot create a user that is missing fields" do
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/users", "test/json/invalid_new_user_1.json")
    %{"errors" => %{"password" => pw_msg, "username" => un_msg}} = resp_body
    assert pw_msg == "This needs to be a string"
    assert un_msg == "This needs to be a string"
    assert status == 400
  end


  test "cannot get a list of users when logged in" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    %{"key" => key} = apikey_resp
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/users", nil, [{"authentication", "foo:#{key}"}])
    assert status == 404
  end

  test "cannot get a list of users when not logged in" do
    DBHelpers.create_user()
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/users")
    assert status == 404
  end

  test "cannot have two users with the same name" do
    DBHelpers.create_user()
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/users", "test/json/new_user_0.json")
    assert status == 400
  end
end
