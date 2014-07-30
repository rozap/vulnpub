

defmodule Test.ApiKeyTest do
  use ExUnit.Case
  use PlugHelper
  require DBHelpers
  setup do
    Fixture.load
    :ok
  end

  test "can create an apikey" do
    {status, req_body, resp_body} = DBHelpers.create_apikey
    assert status == 201
    assert Dict.get(resp_body, "key") != nil
  end

  test "can destroy an apikey" do
    {status, req_body, resp_body} = DBHelpers.create_apikey
    key = Dict.get(resp_body, "key")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :delete, "api/v1/apikey/#{key}", "test/json/del_apikey.json")
    assert status == 202
  end


end
