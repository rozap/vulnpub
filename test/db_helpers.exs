defmodule DBHelpers do
  use PlugHelper

  def create_user(user \\ 0) do
    simulate_json_file(Vulnpub.Router, :post, "api/v1/users", "test/json/new_user_#{user}.json")
  end

  def create_apikey(user \\ 0) do
    DBHelpers.create_user(user)
    simulate_json_file(Vulnpub.Router, :post, "api/v1/apikey", "test/json/new_apikey_#{user}.json")
  end
end