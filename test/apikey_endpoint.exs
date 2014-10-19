

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


  test "can list apikeys" do
    {status, req_body, resp_body} = DBHelpers.create_apikey
    key = Dict.get(resp_body, "key")
    headers = [{"authentication", "foo:#{key}"}]
    {status, _, _} = simulate_json(Vulnpub.Router, :get, "api/v1/apikey", nil, headers)
    assert status == 200
  end

  test "cannot list someone elses apikeys" do
    {_, _, resp} = DBHelpers.create_apikey
    {_, _, other_resp} = DBHelpers.create_apikey(1)
    key = Dict.get(resp, "key")
    other_key = Dict.get(other_resp, "key")
    headers = [{"authentication", "foo:#{key}"}]
    {status, _, index} = simulate_json(Vulnpub.Router, :get, "api/v1/apikey", nil, headers)
    assert status == 200
    %{"data" => [%{"key" => resp_key}]} = index
    assert resp_key == key
    assert resp != other_key
  end


  test "cannot destroy key when not logged in" do
    {status, req_body, resp_body} = DBHelpers.create_apikey
    key = Dict.get(resp_body, "key")
    {status, _, _} = simulate_json_file(Vulnpub.Router, :delete, "api/v1/apikey/#{key}", "test/json/del_apikey.json")
    assert status == 403
  end

  test "cannot destroy someone elses apikey" do
    {_, _, resp} = DBHelpers.create_apikey
    {_, _, other_resp} = DBHelpers.create_apikey(1)
    key = Dict.get(resp, "key")
    other_key = Dict.get(other_resp, "key")
    headers = [{"authentication", "foo:#{key}"}]
    {status, _, _} = simulate_json_file(Vulnpub.Router, :delete, "api/v1/apikey/#{other_key}", "test/json/del_apikey.json", headers)
    assert status == 401
  end




  test "can destroy an apikey" do
    {status, req_body, resp_body} = DBHelpers.create_apikey
    key = Dict.get(resp_body, "key")
    headers = [{"authentication", "foo:#{key}"}]
    {status, _, _} = simulate_json_file(Vulnpub.Router, :delete, "api/v1/apikey/#{key}", "test/json/del_apikey.json", headers)
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
