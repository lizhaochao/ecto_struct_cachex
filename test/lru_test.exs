defmodule LRUTest do
  use ExUnit.Case

  alias ESC.LRU

  @user_1 %User{id: 1, name: "name1", role: %Role{id: 1, name: "r1"}}
  @user_2 %User{id: 2, name: "name2", role: [%Role{id: 2, name: "r2"}, %Role{id: 3, name: "r3"}]}
  @user_3 %User{id: 3, name: "name3", role: %Role{id: 3, name: "r3"}}
  @user_4 %User{id: 4, name: "same_name", role: %Role{id: 4, name: "r4"}}
  @user_5 %User{id: 5, name: "same_name", role: %Role{id: 4, name: "r4"}}

  @list [@user_1, @user_2, @user_3, @user_4, @user_5]

  @list_len length(@list)

  ### ### ### get
  test "empty list - get" do
    assert {nil, []} == LRU.get([], 3, 0)
  end

  test "get by empty cond" do
    expected = {nil, [@user_1, @user_2, @user_3, @user_4, @user_5]}
    assert expected == LRU.get(@list, [], @list_len)
  end

  ##
  test "get by id" do
    expected = {@user_3, [@user_3, @user_1, @user_2, @user_4, @user_5]}
    assert expected == LRU.get(@list, 3, @list_len)
  end

  test "get by id - not found" do
    assert {nil, @list} == LRU.get(@list, 99, @list_len)
  end

  test "get by 2 conds" do
    expected = {@user_3, [@user_3, @user_1, @user_2, @user_4, @user_5]}
    assert expected == LRU.get(@list, [id: 3, name: "name3"], @list_len)
  end

  test "get - found first object" do
    expected = {@user_1, [@user_1, @user_2, @user_3, @user_4, @user_5]}
    assert expected == LRU.get(@list, [name: "name1"], @list_len)
  end

  test "get - found middle object" do
    expected = {@user_2, [@user_2, @user_1, @user_3, @user_4, @user_5]}
    assert expected == LRU.get(@list, [name: "name2"], @list_len)
  end

  test "get - found last object" do
    expected = {@user_4, [@user_4, @user_1, @user_2, @user_3, @user_5]}
    assert expected == LRU.get(@list, [name: "same_name"], @list_len)
  end

  test "get - not found" do
    assert {nil, @list} == LRU.get(@list, [name: "name99"], @list_len)
  end

  ### ### ### put
  test "put" do
    obj = %User{id: 199, name: "name199"}
    assert [obj | @list] == LRU.put(@list, obj)
  end

  test "put - should remove last" do
    user_199 = %User{id: 199, name: "name199"}
    assert [user_199, @user_1, @user_2, @user_3, @user_4] == LRU.put(@list, user_199, 5, 5)
  end
end
