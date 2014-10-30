

defmodule Test.ParseNPMTest do
  use ExUnit.Case
  use PlugHelper

  setup do
    Fixture.load
    :ok
  end


  defp create do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/monitor_npm.json", [{"authentication", "foo:#{key}"}])
    {status, req_body, resp_body, key}
  end

  test "loading a simple package.json file results in the package being added to the monitor" do
    {status, req_body, resp_body, key} = create
    assert Dict.get(req_body, "manifest") == Dict.get(resp_body, "manifest")
    assert Dict.get(req_body, "name") == Dict.get(resp_body, "name")
    id = Dict.get(resp_body, "id")
    :timer.sleep(200)  #packages are loaded async so wait here

    #now get the monitor that was just created back and verify that express is in there with the formatted version
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors/#{id}", nil, [{"authentication", "foo:#{key}"}])
    packages = Enum.sort_by(resp_body["packages"]["data"], &(&1["name"]))
    [
     %{
      "name" => "backbone",
      "version" => "4.2.0",
      "raw_version" => "4.2.0"
      },

      %{
      "name" => "browserify",
      "version" => "*.*.*",
      "raw_version" => "latest"
      },

      %{
      "name" => "express",
      "version" => "3.5.*",
      "raw_version" => "~3.5.1"
      },

      %{
      "name" => "optimist",
      "version" => "0.*.*",
      "raw_version" => "^0.3.4"
      }
    ] = packages
  end


end
