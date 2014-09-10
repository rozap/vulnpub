

defmodule Test.ParserUnmanaged do
  use ExUnit.Case
  use PlugHelper

  setup do
    :timer.sleep(200)  #packages are checked async, so wait a lil bit
    Fixture.load

    :ok
  end


  defp create do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/monitor_manual.json", [{"authentication", "foo:#{key}"}])
    {status, req_body, resp_body, key}
  end

  test "loading a simple package.json file results in the package being added to the monitor" do
    {status, req_body, resp_body, key} = create
    assert Dict.get(req_body, "manifest") == Dict.get(resp_body, "manifest")
    assert Dict.get(req_body, "name") == Dict.get(resp_body, "name")
    id = Dict.get(resp_body, "id")
    :timer.sleep(200)  #packages are loaded async so wait here

    #now get the monitor that was just created back and verify that express is in there with the formatted version
    {_, _, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors/#{id}", nil, [{"authentication", "foo:#{key}"}])

    [some_package, some_other, yet_another] = resp_body["packages"]
    assert some_package["name"] == "some-package-name"
    assert some_other["name"] == "some-other-name"
    assert yet_another["name"] == "yet-another-name"
    assert some_package["version"] == "5.3"
    assert some_other["version"] == "6.3.1"
    assert yet_another["version"] == "0.3.1"
  end


end
