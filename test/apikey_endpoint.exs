

defmodule Test.ApiKeyTest do
  use ExUnit.Case
  use PlugHelper
  require DBHelpers
  setup do
    Fixture.load
    :ok
  end

  test "can create an apikey" do
    {status, _, resp_body} = DBHelpers.create_apikey
    assert status == 201
    assert Dict.get(resp_body, "key") != nil
  end

  test "can destroy an apikey" do
    {status, req_body, resp_body} = DBHelpers.create_apikey
    key = Dict.get(resp_body, "key")
    {status, _, _} = simulate_json_file(Vulnpub.Router, :delete, "api/v1/apikey/#{key}", "test/json/del_apikey.json")
    assert status == 202
  end


  test "cannot create an apikey with the wrong password" do
    DBHelpers.create_user
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/apikey", "test/json/invalid_apikey_0.json")
    assert status == 400
    %{"errors" => %{"username" => msg}} = resp_body
    assert msg == "The username/password combination is invalid"
  end


end
