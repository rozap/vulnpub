

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
    :timer.sleep(800)  #packages are loaded async so wait here

    #now get the monitor that was just created back and verify that express is in there with the formatted version
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors/#{id}", nil, [{"authentication", "foo:#{key}"}])
    [twisted, apt, dateutil, debian, venv] = resp_body["packages"]
    assert twisted["name"] == "Twisted-Web"
    assert apt["name"] == "python-apt"
    assert dateutil["name"] == "python-dateutil"
    assert debian["name"] == "python-debian"
    assert venv["name"] == "virtualenv"

    assert twisted["version"] == "13.2.0"
    assert apt["version"] == "0.9.3.5"
    assert dateutil["version"] == "2.2"
    assert debian["version"] == "0.1.21"
    assert venv["version"] == "1.11.4"

  end


end
