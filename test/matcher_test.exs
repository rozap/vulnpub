

defmodule Test.AlertTest do
  use ExUnit.Case
  use PlugHelper
  alias Service.VulnConsumer, as: M

  test "hits equal matches" do
    assert M.matches?("3.3.3", "== 3.3.3") == true
    assert M.matches?("3.3.2", "== 3.3.3") == false
  end

  test "hits gte matches" do
    assert M.matches?("3.3.3", ">= 3.3.3") == true
    assert M.matches?("3.3.2", ">= 3.3.3") == false
  end

  test "hits gt matches" do
    assert M.matches?("3.3.3", "> 3.3.0") == true
    assert M.matches?("3.3.0", "> 3.3.0") == false
  end

  test "hits lte matches" do
    assert M.matches?("3.3.3", "<= 3.3.4") == true
    assert M.matches?("3.3.5", "<= 3.3.4") == false
  end

  test "hits lt matches" do
    assert M.matches?("3.3.3", "< 3.3.4") == true
    assert M.matches?("3.3.4", "< 3.3.4") == false
  end

  test "hits patch matches" do
    assert M.matches?("3.3.5", "~> 3.3.4") == true
    assert M.matches?("3.4.3", "~> 3.3.4") == false
  end

  

end
