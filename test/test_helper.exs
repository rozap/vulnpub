Code.require_file "plug_helper.exs", __DIR__
Code.require_file "db_fixtures.exs", __DIR__
Code.require_file "db_helpers.exs", __DIR__
Fixture.load


ExUnit.start
