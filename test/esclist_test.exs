defmodule ESClistTest do
  use ExUnit.Case

  @list [1, 2, 3]

  test "add" do
    assert [1, 2, 3, 99] == ESCList.add(@list, 99)
  end

  test "radd" do
    assert [99, 1, 2, 3] == ESCList.radd(@list, 99)
  end

  test "exists?" do
    refute ESCList.exists?(@list, 99)
    assert ESCList.exists?(@list, 1)
  end

  test "del" do
    assert [1, 2, 3] == ESCList.del(@list, 99)
    assert [2, 3] == ESCList.del(@list, 1)
  end

  test "rdel" do
    assert [3, 2, 1] == ESCList.rdel(@list, 99)
    assert [3, 2] == ESCList.rdel(@list, 1)
  end
end
