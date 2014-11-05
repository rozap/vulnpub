

defmodule Test.AlertTest do
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

  defp create_vuln(key, num \\ 0) do
    alert_file = "test/json/alert_vuln_#{num}.json"
    simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", alert_file, 
      [{"authentication", "foo:#{key}"}])
  end


  defp create_monitor(key, num \\ 0) do
    simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", 
      "test/json/alert_monitor_#{num}.json", [{"authentication", "foo:#{key}"}])
  end

  test "when you create a new vuln and have a monitor with that package an 
  alert gets created" do
    key = create_user
    {_, _, mon_response} = create_monitor key
    {_, _, vuln_response} = create_vuln key
    :timer.sleep(20)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 1
    [alert] = resp_body["data"]
    assert alert["monitor"]["id"] == mon_response["id"]
    assert alert["vuln"]["id"] == vuln_response["id"]
  end


  test "version with wrong minor version doesn't make an alert with a tilde spec for the vuln effect" do
    key = create_user
    {_, _, mon_response} = create_monitor key, 3
    {_, _, vuln_response} = create_vuln key, 2
    :timer.sleep(20)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 0
  end

  test "version with a diff patch version does make an alert with a tilde spec for the vuln effect" do
    key = create_user
    {_, _, mon_response} = create_monitor key
    {_, _, vuln_response} = create_vuln key, 3
    :timer.sleep(20)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 1
  end


  test "version with lt qualifier works" do
    key = create_user
    {_, _, mon_response} = create_monitor key
    {_, _, vuln_response} = create_vuln key, 4
    :timer.sleep(20)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 1
  end


  test "version with gt qualifier works" do
    key = create_user
    {_, _, mon_response} = create_monitor key
    {_, _, vuln_response} = create_vuln key, 4
    :timer.sleep(20)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 1
  end

  test "when you create a new vuln and have a monitor with a package of a higher version number, no alert gets created" do
    key = create_user
    {_, _, mon_response} = create_monitor key, 1
    {_, _, vuln_response} = create_vuln key
    :timer.sleep(20)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 0
  end

  test "falling outside of safe versions in a vuln causes an alert" do
    key = create_user
    {_, _, mon_response} = create_monitor key, 2
    {_, _, vuln_response} = create_vuln key, 6
    :timer.sleep(20)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 1
  end

  test "falling inside of safe versions in a vuln does not cause an alert" do
    key = create_user
    {_, _, mon_response} = create_monitor key, 2
    {_, _, vuln_response} = create_vuln key, 7
    :timer.sleep(20)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 0
  end

  test "falling inside of safe versions but matching a vulnerable version
   causes an alert" do
    key = create_user
    {_, _, mon_response} = create_monitor key, 2
    {_, _, vuln_response} = create_vuln key, 8
    :timer.sleep(20)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 1
  end

  test "wildcard patch version matches a vuln" do
    key = create_user
    {_, _, mon_response} = create_monitor key, 4
    IO.inspect mon_response

    id = mon_response["id"]
    {_, _, monitor_resp} = simulate_json(
      Vulnpub.Router, 
      :get, 
      "api/v1/monitors/#{id}", 
      nil, 
      [{"authentication", "foo:#{key}"}]
    )


    IO.inspect monitor_resp

    {_, _, vuln_response} = create_vuln key, 9
    :timer.sleep(20)  #packages are checked async, so wait a lil bit
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert resp_body["meta"]["count"] == 1
  end




  

end
