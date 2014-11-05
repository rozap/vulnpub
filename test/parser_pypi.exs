

defmodule Test.ParserPyPiTest do
  use ExUnit.Case
  use PlugHelper

  setup do
    Fixture.load
    :ok
  end


  defp create do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/monitor_pypi.json", [{"authentication", "foo:#{key}"}])
    {status, req_body, resp_body, key}
  end

  test "loading a simple requirements.txt file results in the package being added to the monitor" do
    {status, req_body, resp_body, key} = create
    assert Dict.get(req_body, "manifest") == Dict.get(resp_body, "manifest")
    assert Dict.get(req_body, "name") == Dict.get(resp_body, "name")
    id = Dict.get(resp_body, "id")
    :timer.sleep(500)  #packages are loaded async so wait here

    #now get the monitor that was just created back and verify that express is in there with the formatted version
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors/#{id}", nil, [{"authentication", "foo:#{key}"}])
    packages = resp_body["packages"]["data"]
    packages = Enum.sort_by(resp_body["packages"]["data"], &(&1["name"]))
    IO.inspect packages
    [
      %{"name" => "Twisted-Web", "version" => "13.2.0"},
      %{"name" => "python-apt", "version" => "0.9.3"},
      %{"name" => "python-dateutil", "version" => "2.2.*"},
      %{"name" => "python-debian", "version" => "0.1.21"},
      %{"name" => "virtualenv", "version" => "1.11.4"}
    ] = packages

  end


end
