

defmodule Test.VulnConsumerTest do
  use ExUnit.Case
  use PlugHelper

  setup do
    Fixture.load
    :ok
  end





  defp create_vuln(n \\ 0) do
    file = "test/json/retroactive_vuln_#{n}.json"
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", file, [{"authentication", "foo:#{key}"}])
  end
 

  defp create_monitor(n \\ 0) do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/retroactive_monitor_#{n}.json", [{"authentication", "foo:#{key}"}])
  end

  test "makes a new alert when you add a monitor that matches an old vuln" do
    {status, _, _} = create_vuln(0)
    assert status == 201
    {status, _, _} = create_vuln(1)
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
    %{"data" => [
      %{
        "vuln" => %{
          "name" => "retroactive_vuln"
        }
      }], "meta" => %{"count" => 1, "next" => 1, "pages" => 0}} = resp_body
    end


  test "makes new alerts when you add a monitor that matches > 1 old vulns" do
    {status, _, _} = create_vuln(0)
    assert status == 201
    {status, _, _} = create_vuln(1)
    assert status == 201
    {status, _, _} = create_monitor(1)
    assert status == 201
    :timer.sleep(200)
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, _, resp_body} = simulate_json(Vulnpub.Router, :get,
       "api/v1/alerts", nil, [{"authentication", "foo:#{key}"}])
    assert status == 200
    %{"data" => alerts, "meta" => %{"count" => 2, "next" => 1, "pages" => 0}} = resp_body
    alerts = Enum.sort_by(alerts, fn alert -> alert["vuln"]["name"] end)
    IO.inspect alerts
    [%{
        "vuln" => %{
          "name" => "baz2"
        }
      },
      %{
        "vuln" => %{
          "name" => "retroactive_vuln"
        }
    }] = alerts
    end


end
