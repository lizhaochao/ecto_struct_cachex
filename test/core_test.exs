defmodule CoreTest do
  use ExUnit.Case

  alias ESC.Core

  @user_1 %User{id: 1, name: "name1", role: %Role{id: 1, name: "r1"}}
  @user_2 %User{id: 2, name: "name2", role: [%Role{id: 2, name: "r2"}, %Role{id: 3, name: "r3"}]}
  @user_3 %User{id: 3, name: "name3", role: %Role{id: 3, name: "r3"}}
  @user_4 %User{id: 4, name: "same_name", role: %Role{id: 4, name: "r4"}}
  @user_5 %User{id: 5, name: "same_name", role: %Role{id: 4, name: "r4"}}

  @list [@user_1, @user_2, @user_3, @user_4, @user_5]

  ###
  describe "delete_by_struct" do
    test "del one - map" do
      assert [@user_2, @user_3, @user_4, @user_5] == Core.delete_by_struct(@list, Role, 1)
    end

    test "del two - map" do
      assert [@user_1, @user_2, @user_3] == Core.delete_by_struct(@list, Role, 4)
    end

    test "del one - in list" do
      assert [@user_1, @user_3, @user_4, @user_5] == Core.delete_by_struct(@list, Role, 2)
    end

    test "del two - mixed map & list" do
      assert [@user_1, @user_4, @user_5] == Core.delete_by_struct(@list, Role, 3)
    end

    test "del nothing" do
      assert @list == Core.delete_by_struct(@list, Role, 99)
    end
  end
end
