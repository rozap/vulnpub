

defmodule Test.ParseRubyGemsTest do
  use ExUnit.Case
  use PlugHelper

  setup do
    Fixture.load
    :ok
  end


  defp create do
    {_, _, apikey_resp} = DBHelpers.create_apikey()
    key = Dict.get(apikey_resp, "key")
    {status, req_body, resp_body} = simulate_json_file(
      Vulnpub.Router, 
      :post, 
      "api/v1/monitors", 
      "test/json/monitor_gems.json", 
      [{"authentication", "foo:#{key}"}]
    )
    {status, req_body, resp_body, key}
  end

  test "loading a gemfile results in the packages being added to the monitor" do
    {status, req_body, resp_body, key} = create
    assert Dict.get(req_body, "manifest") == Dict.get(resp_body, "manifest")
    assert Dict.get(req_body, "name") == Dict.get(resp_body, "name")
    id = Dict.get(resp_body, "id")
    :timer.sleep(800)  #packages are loaded async so wait here

    #now get the monitor that was just created back and verify that express is in there with the formatted version
    {status, req_body, resp_body} = simulate_json(Vulnpub.Router, :get, "api/v1/monitors/#{id}", nil, [{"authentication", "foo:#{key}"}])
    packages = Enum.sort_by(resp_body["packages"]["data"], &(&1["name"]))
    
    Enum.map(packages, fn p -> 
      %{"name" => name, "version" => version, "raw_version" => rv} = p
      IO.puts("name #{name} version #{version} rv #{rv}")
    end)

    [%{"name" => "active_model_serializers", "version" => "*.*.*"},
    %{"name" => "analytics-ruby", "version" => "2.0.*", "raw_version" => "~> 2.0.0"},
    %{"name" => "angularjs-rails", "version" => "*.*.*"},
    %{"name" => "attr_extras", "version" => "*.*.*"},
    %{"name" => "bourbon", "version" => "*.*.*"},
    %{"name" => "byebug", "version" => "*.*.*"},
    %{"name" => "capybara", "version" => "2.4.*"},
    %{"name" => "capybara-webkit", "version" => "*.*.*"},
    %{"name" => "coffee-rails", "version" => "*.*.*"},
    %{"name" => "coffeelint", "version" => "*.*.*"},
    %{"name" => "database_cleaner", "version" => "*.*.*"},
    %{"name" => "factory_girl_rails", "version" => "*.*.*"},
    %{"name" => "font-awesome-rails", "version" => "*.*.*"},
    %{"name" => "foreman", "version" => "*.*.*"},
    %{"name" => "haml-rails", "version" => "*.*.*"},
    %{"name" => "high_voltage", "version" => "*.*.*"},
    %{"name" => "jquery-rails", "version" => "*.*.*"},
    %{"name" => "jshintrb", "version" => "*.*.*"},
    %{"name" => "konacha", "version" => "*.*.*"},
    %{"name" => "launchy", "version" => "*.*.*"},
    %{"name" => "neat", "version" => "*.*.*"},
    %{"name" => "newrelic_rpm", "version" => "*.*.*"},
    %{"name" => "octokit", "version" => "*.*.*"},
    %{"name" => "omniauth-github", "version" => "*.*.*"},
    %{"name" => "paranoia", "raw_version" => "~> 2.0", "version" => "2.0.*"},
    %{"name" => "pg", "version" => "*.*.*"},
    %{"name" => "poltergeist", "version" => "*.*.*"},
    %{"name" => "rails", "raw_version" => "4.1.5", "version" => "4.1.5"},
    %{"name" => "rails_12factor", "version" => "*.*.*"},
    %{"name" => "resque", "raw_version" => "~> 1.22.0", "version" => "1.22.*"},
    %{"name" => "resque-retry", "version" => "*.*.*"},
    %{"name" => "resque-sentry", "version" => "*.*.*"},
    %{"name" => "rspec-rails", "version" => "*.*.*"},
    %{"name" => "rubocop", "raw_version" => "0.25.0", "version" => "0.25.0"},
    %{"name" => "sass-rails", "raw_version" => "~> 4.0.2", "version" => "4.0.*"},
    %{"name" => "sentry-raven", "version" => "*.*.*"},
    %{"name" => "shoulda-matchers", "version" => "*.*.*"},
    %{"name" => "stripe", "version" => "*.*.*"},
    %{"name" => "uglifier", "raw_version" => ">= 1.0.3", "version" => "*.*.*"},
    %{"name" => "unicorn", "version" => "*.*.*"},
    %{"name" => "webmock", "version" => "*.*.*"}] = packages


  end


end
