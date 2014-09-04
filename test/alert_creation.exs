

defmodule Test.VulnTest do
  use ExUnit.Case
  use PlugHelper

  setup do
    Fixture.load
    :ok
  end


  defp create_user do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    Dict.get(apikey_resp, "key")
  end

  defp create_vuln(key) do
    simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", "test/json/alert_vuln.json", [{"authentication", "foo:#{key}"}])
  end


  defp create_monitor(key, num \\ 0) do
    simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/alert_monitor_#{num}.json", [{"authentication", "foo:#{key}"}])
  end

  test "when you create a new vuln and have a monitor with that package an alert gets created" do
    key = create_user
    {_, _, mon_response} = create_monitor key
    {_, _, vuln_response} = create_vuln key
    :timer.sleep(200)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 1
    [alert] = resp_body["data"]
    assert alert["monitor"]["id"] == mon_response["id"]
    assert alert["vuln"]["id"] == vuln_response["id"]
  end


  test "when you create a new vuln and have a monitor with a package of a higher version number, no alert gets created" do
    key = create_user
    {_, _, mon_response} = create_monitor key, 1
    {_, _, vuln_response} = create_vuln key
    :timer.sleep(200)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 0
  end


end