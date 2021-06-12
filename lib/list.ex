defmodule ESCList do
  @moduledoc false

  def add(list, val) when is_list(list), do: list ++ [val]
  def radd(list, val) when is_list(list), do: [val | list]
  def exists?(list, val) when is_list(list), do: val in list

  def rdel(list, val) when is_list(list), do: do_del(list, val, [])
  def del(list, val) when is_list(list), do: do_del(list, val, []) |> Enum.reverse()
  def do_del([], _val, acc), do: acc
  def do_del([item | rest], val, acc) when item == val, do: do_del(rest, val, acc)
  def do_del([item | rest], val, acc), do: do_del(rest, val, [item | acc])
end
