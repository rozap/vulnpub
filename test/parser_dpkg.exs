

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
    packages = Enum.sort_by(resp_body["packages"]["data"], &(&1["name"]))
    IO.inspect packages

  [
   %{"name" => "bind9-host", "raw_version" => "1:9.9.5.dfsg-3",                "version" => "9.9.5"},
   %{"name" => "binutils",   "raw_version" => "2.24-5ubuntu3",                 "version" => "2.24.0"},
   %{"name" => "blueman",    "raw_version" => "1.23-git201403102151-1ubuntu1", "version" => "1.23.0"},
   %{"name" => "bluez",      "raw_version" => "4.101-0ubuntu13",               "version" => "4.101.0"},
   %{"name" => "nodejs",     "raw_version" => "0.10.25~dfsg2-2ubuntu1",        "version" => "0.10.25"},
   %{"name" => "npm",        "raw_version" => "1.3.10~dfsg-1",                 "version" => "1.3.10"}
  ] = packages


  end


end
