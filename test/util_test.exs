

defmodule Test.UtilTest do
  use ExUnit.Case, async: true
  require Util




  test "test util.past for dates in past" do
    dt = Util.past([year: 2, month: 2])
  end

end
