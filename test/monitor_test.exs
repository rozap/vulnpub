

defmodule Test.MonitorTest do
  use ExUnit.Case
  use PlugHelper


  defp create do
    {conn, req_body} = simulate_json(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_monitor.json")
    {:ok, resp_body} = JSON.decode(conn.resp_body)
    assert Dict.get(req_body, "manifest") == Dict.get(resp_body, "manifest")
    assert Dict.get(req_body, "name") == Dict.get(resp_body, "name")
    id = Dict.get(resp_body, "id")
    assert id != nil
    id
  end

  test "can create a monitor" do
    create()
  end

  test "can get a list of monitors" do
    conn = simulate_request(Vulnpub.Router, :get, "api/v1/monitors")
    {:ok, resp_body} = JSON.decode(conn.resp_body)
    assert length(resp_body) > 0
  end


  test "can update a monitor" do
    id = create()
    {conn, req_body} = simulate_json(Vulnpub.Router, :put, "api/v1/monitors/#{id}", "test/json/update_monitor.json")
    {:ok, resp_body} = JSON.decode(conn.resp_body)
  end

end
