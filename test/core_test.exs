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
  @list_len length(@list)

  ###
  describe "delete_by_struct" do
    test "del one - deep 2 level map" do
      {del_ids, list} = Core.delete_by_struct(@list, Child, 1)
      assert [@user_2, @user_3, @user_4, @user_5] == list
      assert [1] == del_ids
    end

    test "del one - deep 2 level list" do
      {del_ids, list} = Core.delete_by_struct(@list, Child, 2)
      assert [@user_1, @user_3, @user_4, @user_5] == list
      assert [2] == del_ids
    end

    test "del one - map" do
      {del_ids, list} = Core.delete_by_struct(@list, Parent, 1)
      assert [@user_2, @user_3, @user_4, @user_5] == list
      assert [1] == del_ids
    end

    test "del two - map" do
      {del_ids, list} = Core.delete_by_struct(@list, Parent, 4)
      assert [@user_1, @user_2, @user_3] == list
      assert [5, 4] == del_ids
    end

    test "del one - in list" do
      {del_ids, list} = Core.delete_by_struct(@list, Parent, 2)
      assert [@user_1, @user_3, @user_4, @user_5] == list
      assert [2] == del_ids
    end

    test "del two - mixed map & list" do
      {del_ids, list} = Core.delete_by_struct(@list, Parent, 3)
      assert [@user_1, @user_4, @user_5] == list
      assert [3, 2] == del_ids
    end

    test "del nothing - 1 level" do
      {del_ids, list} = Core.delete_by_struct(@list, Parent, 99)
      assert @list == list
      assert [] == del_ids
    end

    test "del nothing - deep 2 level" do
      {del_ids, list} = Core.delete_by_struct(@list, Child, 99)
      assert @list == list
      assert [] == del_ids
    end

    test "del nothing - unknown struct" do
      {del_ids, list} = Core.delete_by_struct(@list, Unknown, 99)
      assert @list == list
      assert [] == del_ids
    end
  end

  describe "delete" do
    test "by id" do
      assert [@user_2, @user_3, @user_4, @user_5] == Core.delete(@list, 1, @list_len)
    end

    test "by conds - del one" do
      assert [@user_2, @user_3, @user_4, @user_5] == Core.delete(@list, [id: 1], @list_len)
    end

    test "by conds - not exists id" do
      assert [@user_1, @user_2, @user_3, @user_4, @user_5] == Core.delete(@list, [id: 999], @list_len)
    end

    test "by conds - del two" do
      assert [@user_1, @user_2, @user_3] == Core.delete(@list, [name: "same_n"], @list_len)
    end

    test "by conds - empty list" do
      assert [] == Core.delete([], [name: "same_n"], @list_len)
    end
  end

  describe "get_refs/1" do
    test "map" do
      assert {:ok, {User, MapSet.new([Parent])}} == Core.get_refs(@user_3)
    end

    test "nested map" do
      assert {:ok, {User, MapSet.new([Parent, Child])}} == Core.get_refs(@user_1)
    end

    test "list" do
      assert {:ok, {User, MapSet.new([Parent, Child])}} == Core.get_refs(@user_2)
    end

    test "no refs" do
      assert {:ok, {Role, %MapSet{}}} == Core.get_refs(%Role{id: 1, name: "role name"})
    end

    test "error" do
      assert :obj_is_not_struct == Core.get_refs(%{id: 1, name: "name"})
    end
  end
end
