defmodule DBHelpers do
  use PlugHelper

  def create_user do
    simulate_json_file(Vulnpub.Router, :post, "api/v1/users", "test/json/new_user.json")
  end

  def create_apikey do
    DBHelpers.create_user
    simulate_json_file(Vulnpub.Router, :post, "api/v1/apikey", "test/json/new_apikey.json")
  end
end