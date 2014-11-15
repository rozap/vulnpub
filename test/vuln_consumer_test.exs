

defmodule Test.VulnConsumerTest do
  use ExUnit.Case
  use PlugHelper

  setup do
    Fixture.load
    :ok
  end





  defp create(file \\ "test/json/new_vuln.json") do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", file, [{"authentication", "foo:#{key}"}])
  end
 

  defp create_monitor do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_monitor_1.json", [{"authentication", "foo:#{key}"}])
  end

  test "sends a digest of stuff on a new monitor" do
    {status, _, _} = create
    assert status == 201
    {status, _, _} = create_monitor
    assert status == 201
    :timer.sleep(200)
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, _, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert status == 200
    IO.inspect resp_body
    %{"data" => [alerts], "meta" => %{"count" => 1, "next" => 1, "pages" => 0}} = resp_body
  end


end
