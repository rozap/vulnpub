

defmodule Test.VulnTest do
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

  #remove load from file here...
  test "can create a vuln" do
    {status, req_body, resp_body} = create
    IO.inspect resp_body
    %{
      "description" => "foo",
      "name" => "baz",
      "external_link" => "http://some-blog/post",
      "effects" => [
        %{
            "vulnerable" => true,
            "package" => %{
              "version" => "4.20.0",
              "name" => "some-package-name"
            }
          }
      ]
    } = resp_body
    assert status == 201
  end


  #remove load from file here...
  test "invalid version in package" do
    {status, req_body, resp_body} = create("test/json/invalid_vuln_version.json")
    %{"errors" => 
      [
        %{"version" => "4.20 is an invalid version"}
      ]
      } = resp_body
    assert status == 400
  end


  test "can't create with a bogus apikey" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", "test/json/new_vuln.json", [{"authentication", "foo:something"}])
    assert status == 403
  end

  test "can't create invalid vuln" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, req_body, resp_body}  = simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", "test/json/invalid_new_vuln.json", [{"authentication", "foo:#{key}"}])
    assert status == 400
  end

  test "cannot create a vuln if not logged in" do
    {status, req_body, resp_body} = simulate_json_file(Vulnpub.Router, :post, "api/v1/vulns", "test/json/new_vuln.json")
    assert status == 403
  end

  #decide if this functionality is warranted
  # test "cannot get vulns if not logged in" do
  #   {status, resp_body} = simulate_request_unauth(Vulnpub.Router, :get, "api/v1/vulns")
  #   assert status == 403
  # end

  test "can get vulns if logged in" do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    headers = [{"authentication", "foo:#{key}"}]
    simulate_json_file(Vulnpub.Router, :post, "api/v1/monitors", "test/json/new_vuln.json", headers)
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/vulns", nil, headers)
    assert status == 200
  end

end