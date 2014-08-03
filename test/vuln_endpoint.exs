

defmodule Test.VulnTest do
  use ExUnit.Case
  use PlugHelper

  setup do
    Fixture.load
    :ok
  end


  defp create do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", "test/json/new_vuln.json", [{"authentication", "foo:#{key}"}])
  end

  test "can create a vuln" do
    {status, req_body, resp_body} = create
    assert Dict.get(req_body, "description") == Dict.get(resp_body, "description")
    assert Dict.get(req_body, "name") == Dict.get(resp_body, "name")
    assert Dict.get(req_body, "external_link") == Dict.get(resp_body, "external_link")
    assert Dict.get(req_body, "effects_version") == Dict.get(resp_body, "effects_version")

    id = Dict.get(resp_body, "id")
    assert status == 201
    assert id != nil
  end

  test "can't create with a bogus apikey" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", "test/json/new_vuln.json", [{"authentication", "foo:something"}])
    assert status == 403
  end

  test "can't create invalid vuln" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, req_body, resp_body}  = simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", "test/json/invalid_new_vuln.json", [{"authentication", "foo:#{key}"}])
    assert status == 400
  end

  test "cannot create a vuln if not logged in" do
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", "test/json/new_vuln.json")
    assert status == 403
  end

  test "cannot get vulns if not logged in" do
    {status, resp_body} = simulate_request_unauth(Vulnpub.Router, :get, "api/v1/vulns")
    assert status == 403
  end

  test "can get vulns if logged in" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    headers = [{"authentication", "foo:#{key}"}]
    simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_vuln.json", headers)
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/vulns", nil, headers)
    assert status == 200
  end

end