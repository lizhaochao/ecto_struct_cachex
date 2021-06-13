defmodule User do
  defstruct [:id, :name]
end

defmodule LRUBench do
  use Benchfella

  @lru_list [
    %User{id: 1, name: "name1"},
    %User{id: 2, name: "name2"},
    %User{id: 3, name: "name3"},
    %User{id: 4, name: "same_name"},
    %User{id: 5, name: "same_name"}
  ]
  @obj %User{id: 9, name: "n9"}
  @list_len length(@lru_list)
  @capacity @list_len

  ### put operate
  bench("only put", do: ESC.LRU.put(@lru_list, @obj))
  bench("put - should remove", do: ESC.LRU.put(@lru_list, @obj, @list_len, @capacity))

  ### get operate
  bench("get - empty cond", do: ESC.LRU.get(@lru_list, [], @list_len))
  bench("get - by id - obj at top", do: ESC.LRU.get(@lru_list, 1, @list_len))
  bench("get - by conds - obj at top", do: ESC.LRU.get(@lru_list, [id: 1], @list_len))
  bench("get - by conds - obj at mid", do: ESC.LRU.get(@lru_list, [id: 3], @list_len))
  bench("get - by conds - obj at bottom", do: ESC.LRU.get(@lru_list, [id: 5], @list_len))
end
