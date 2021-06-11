defmodule User do
  defstruct [:id, :name]
end

defmodule LRUTest do
  use ExUnit.Case

  alias ESC.LRU

  @list [
    %User{id: 1, name: "name1"},
    %User{id: 2, name: "name2"},
    %User{id: 3, name: "name3"},
    %User{id: 4, name: "same_name"},
    %User{id: 5, name: "same_name"}
  ]

  @list_len length(@list)

  ### ### ### get
  test "empty list - get" do
    assert {nil, []} == LRU.get([], 3, 0)
  end

  test "get by empty cond" do
    expected =
      {nil,
       [
         %User{id: 1, name: "name1"},
         %User{id: 2, name: "name2"},
         %User{id: 3, name: "name3"},
         %User{id: 4, name: "same_name"},
         %User{id: 5, name: "same_name"}
       ]}

    assert expected == LRU.get(@list, [], @list_len)
  end

  ##
  test "get by id" do
    expected =
      {%User{id: 3, name: "name3"},
       [
         %User{id: 3, name: "name3"},
         %User{id: 1, name: "name1"},
         %User{id: 2, name: "name2"},
         %User{id: 4, name: "same_name"},
         %User{id: 5, name: "same_name"}
       ]}

    assert expected == LRU.get(@list, 3, @list_len)
  end

  test "get by id - not found" do
    assert {nil, @list} == LRU.get(@list, 99, @list_len)
  end

  test "get by 2 conds" do
    expected =
      {%User{id: 3, name: "name3"},
       [
         %User{id: 3, name: "name3"},
         %User{id: 1, name: "name1"},
         %User{id: 2, name: "name2"},
         %User{id: 4, name: "same_name"},
         %User{id: 5, name: "same_name"}
       ]}

    assert expected == LRU.get(@list, [id: 3, name: "name3"], @list_len)
  end

  test "get - found first object" do
    expected =
      {%User{id: 1, name: "name1"},
       [
         %User{id: 1, name: "name1"},
         %User{id: 2, name: "name2"},
         %User{id: 3, name: "name3"},
         %User{id: 4, name: "same_name"},
         %User{id: 5, name: "same_name"}
       ]}

    assert expected == LRU.get(@list, [name: "name1"], @list_len)
  end

  test "get - found middle object" do
    expected =
      {%User{id: 2, name: "name2"},
       [
         %User{id: 2, name: "name2"},
         %User{id: 1, name: "name1"},
         %User{id: 3, name: "name3"},
         %User{id: 4, name: "same_name"},
         %User{id: 5, name: "same_name"}
       ]}

    assert expected == LRU.get(@list, [name: "name2"], @list_len)
  end

  test "get - found last object" do
    expected =
      {%User{id: 4, name: "same_name"},
       [
         %User{id: 4, name: "same_name"},
         %User{id: 1, name: "name1"},
         %User{id: 2, name: "name2"},
         %User{id: 3, name: "name3"},
         %User{id: 5, name: "same_name"}
       ]}

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
end
