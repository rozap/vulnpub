

defmodule Test.VersionTest do
  use ExUnit.Case, async: true
  use PlugHelper
  alias VPVersion, as: V



  test "parse all wildcard" do
    {:ok, version} = V.parse("*.*.*")
    assert V.to_matchable(version) == {:any, :any, :any, []}
  end

  test "parse minor wildcard" do
    {:ok, version} = V.parse("3.*.*")
    assert V.to_matchable(version) == {3, :any, :any, []}
  end   

  test "parse minor wildcard" do
    {:ok, version} = V.parse("3.1.*")
    assert V.to_matchable(version) == {3, 1, :any, []}
  end   
end
