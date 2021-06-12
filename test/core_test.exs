defmodule CoreTest do
  use ExUnit.Case

  alias ESC.Core

  @user_1 %User{id: 1, role: %Parent{id: 1, name: "r1", child: %Child{id: 1}}, name: "n1"}
  @user_2 %User{
    id: 2,
    role: [
      %Parent{id: 2, name: "r2"},
      %Parent{id: 3, name: "r3", child: %Child{id: 2}}
    ],
    name: "n2"
  }
  @user_3 %User{id: 3, name: "n3", role: %Parent{id: 3, name: "r3"}}
  @user_4 %User{id: 4, name: "same_n", role: %Parent{id: 4, name: "r4"}}
  @user_5 %User{id: 5, name: "same_n", role: %Parent{id: 4, name: "r4"}}

  @list [@user_1, @user_2, @user_3, @user_4, @user_5]

  ###
  describe "delete_by_struct" do
    test "del one - deep 2 level map" do
      assert [@user_2, @user_3, @user_4, @user_5] == Core.delete_by_struct(@list, Child, 1)
    end

    test "del one - deep 2 level list" do
      assert [@user_1, @user_3, @user_4, @user_5] == Core.delete_by_struct(@list, Child, 2)
    end

    test "del one - map" do
      assert [@user_2, @user_3, @user_4, @user_5] == Core.delete_by_struct(@list, Parent, 1)
    end

    test "del two - map" do
      assert [@user_1, @user_2, @user_3] == Core.delete_by_struct(@list, Parent, 4)
    end

    test "del one - in list" do
      assert [@user_1, @user_3, @user_4, @user_5] == Core.delete_by_struct(@list, Parent, 2)
    end

    test "del two - mixed map & list" do
      assert [@user_1, @user_4, @user_5] == Core.delete_by_struct(@list, Parent, 3)
    end

    test "del nothing - 1 level" do
      assert @list == Core.delete_by_struct(@list, Parent, 99)
    end

    test "del nothing - deep 2 level" do
      assert @list == Core.delete_by_struct(@list, Child, 99)
    end

    test "del nothing - unknown struct" do
      assert @list == Core.delete_by_struct(@list, Unknown, 99)
    end
  end
end
