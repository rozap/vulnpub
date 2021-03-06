

defmodule Test.MonitorTest do
  use ExUnit.Case
  use PlugHelper

  setup do
    Fixture.load
    :ok
  end


  defp create do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_monitor.json", [{"authentication", "foo:#{key}"}])
  end

  test "can create a monitor" do
    {status, req_body, resp_body} = create
    assert Dict.get(req_body, "manifest") == Dict.get(resp_body, "manifest")
    assert Dict.get(req_body, "name") == Dict.get(resp_body, "name")
    id = Dict.get(resp_body, "id")
    assert id != nil
  end

  test "invalid manifest says inaccessible" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    headers = [{"authentication", "foo:#{key}"}]
    {_, _, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/inaccessible_monitor.json", headers)
    %{"id" => id} = resp_body
    assert id != nil
    :timer.sleep(200) 
    {_, _, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors/#{id}", nil, headers)
    %{"status" => "HTTPError: foo not accessible!"} = resp_body
  end


  test "invalid json manifest says so" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    headers = [{"authentication", "foo:#{key}"}]
    {_, _, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/invalid_json_monitor.json", headers)
    %{"id" => id} = resp_body
    assert id != nil
    :timer.sleep(200) 
    {_, _, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors/#{id}", nil, headers)
    %{"status" => "JSON Error: http://localhost:7777/manifest_invalid_json.json does not contain valid JSON."} = resp_body
  end

  test "cannot create a monitor if not logged in" do
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_monitor.json")
    assert status == 403
  end

  test "cannot get monitors if not logged in" do
    {status, resp_body} = simulate_request_unauth(Vulnpub.Router, :get, "api/v1/monitors")
    assert status == 403
  end

  test "can get monitors if logged in" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    headers = [{"authentication", "foo:#{key}"}]
    simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_monitor.json", headers)
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors", nil, headers)
    assert status == 200
  end

  test "only get your monitors" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    headers = [{"authentication", "foo:#{key}"}]
    simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_monitor.json", headers)
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors", nil, headers)
    assert status == 200
  end



  test "can update a monitor" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {_, _, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_monitor.json", [{"authentication", "foo:#{key}"}])
    id = Dict.get(resp_body, "id")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :put, "api/v1/monitors/#{id}", "test/json/update_monitor.json", [{"authentication", "foo:#{key}"}])
    assert status == 202
  end


  test "can delete a monitor" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    headers = [{"authentication", "foo:#{key}"}]
    {_, _, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_monitor.json", headers)
    id = Dict.get(resp_body, "id")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :delete, "api/v1/monitors/#{id}", "test/json/update_monitor.json", headers)
    assert status == 202
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors", nil, headers)
    assert status == 200
    assert resp_body["data"] === []
  end

  test "cannot update someone elses monitor" do
    {_, _, resp} = DBHelpers.create_apikey(1)
    bad_key = Dict.get(resp, "key")
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {_, _, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_monitor.json", [{"authentication", "foo:#{key}"}])
    id = Dict.get(resp_body, "id")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :put, "api/v1/monitors/#{id}", "test/json/update_monitor.json", [{"authentication", "foo_1:#{bad_key}"}])
    assert status == 401
  end

  test "cannot update someone elses monitor" do
    {_, _, resp} = DBHelpers.create_apikey(1)
    bad_key = Dict.get(resp, "key")
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {_, _, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_monitor.json", [{"authentication", "foo:#{key}"}])
    id = Dict.get(resp_body, "id")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :delete, "api/v1/monitors/#{id}", "test/json/update_monitor.json", [{"authentication", "foo_1:#{bad_key}"}])
    assert status == 401
  end

end
