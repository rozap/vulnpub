

defmodule Test.ParseDpkgTest do
  use ExUnit.Case
  use PlugHelper

  setup do
    Fixture.load
    :ok
  end


  defp create do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/monitor_dpkg.json", [{"authentication", "foo:#{key}"}])
    {status, req_body, resp_body, key}
  end

  test "loading a simple package.json file results in the package being added to the monitor" do
    {status, req_body, resp_body, key} = create
    assert Dict.get(req_body, "manifest") == Dict.get(resp_body, "manifest")
    assert Dict.get(req_body, "name") == Dict.get(resp_body, "name")
    id = Dict.get(resp_body, "id")
    :timer.sleep(1000)  #packages are loaded async so wait here

    #now get the monitor that was just created back and verify that express is in there with the formatted version
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors/#{id}", nil, [{"authentication", "foo:#{key}"}])
    IO.inspect resp_body
    [nodejs, npm, bind9, binutils, blueman, bluez] = resp_body["packages"]["data"]
    assert nodejs["name"] == "nodejs"
    assert npm["name"] == "npm"
    assert nodejs["version"] == "0.10.25"
    assert npm["version"] == "1.3.10"
    assert bluez["version"] == "4.101.0"
    assert blueman["version"] == "1.23.0"
    assert binutils["version"] == "2.24.0"
    assert bind9["version"] == "9.9.5"
  end


end
