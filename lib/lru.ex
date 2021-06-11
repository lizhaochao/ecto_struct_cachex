defmodule ESC.LRU do
  @moduledoc false

  @empty_cond_idx 0
  @obj_at_top_idx 1

  ###
  def put(list, %_{} = obj)
      when is_list(list),
      do: [obj | list]

  def get(list, id, len)
      when is_list(list) and is_integer(id) and is_integer(len) and len >= 0,
      do: list |> get_by_conds({id}) |> make_result(list, len)

  def get(list, conds, len)
      when is_list(list) and is_list(conds) and is_integer(len) and len >= 0,
      do: list |> get_by_conds(conds) |> make_result(list, len)

  ###
  def get_by_conds(list, conds) do
    {_found, _left, _idx} = init = {nil, 0, []}
    do_get_by_conds(init, list, conds)
  end

  def do_get_by_conds({found, idx, _left}, list, [] = _conds), do: {found, idx, list}
  def do_get_by_conds({found, idx, left}, [] = _list, _conds), do: {found, idx, left}

  def do_get_by_conds({found, idx, left}, [%_{id: id} = obj | rest], {expected_id} = conds) do
    found? = expected_id == id
    break_or_continue({found, idx, left}, [%_{} = obj | rest], conds, found?)
  end

  def do_get_by_conds({found, idx, left}, [%_{} = obj | rest], conds) do
    found? = found?(obj, conds, found)
    break_or_continue({found, idx, left}, [%_{} = obj | rest], conds, found?)
  end

  def break_or_continue({found, idx, left}, [%_{} = obj | rest], conds, found?) do
    rest = if found?, do: [], else: rest
    new_idx = idx + 1

    found?
    |> if(do: {obj, new_idx, left}, else: {found, new_idx, [obj | left]})
    |> do_get_by_conds(rest, conds)
  end

  def make_result({_found, _idx, _left}, [] = list, 0 = _len), do: {nil, list}

  def make_result({found, idx, _left}, list, _len)
      when idx in [@empty_cond_idx, @obj_at_top_idx],
      do: {found, list}

  def make_result({found, idx, left}, list, len)
      when len == idx,
      do: {found, make_left(list, left, found)}

  def make_result({found, idx, left}, list, len) do
    new_list = make_left(list, left, found) ++ make_right(list, len, idx)
    {found, new_list}
  end

  ###
  def found?(%_{} = _obj, [] = _conds, nil = _found), do: false

  def found?(%_{} = obj, [_ | _] = conds, nil = _found) do
    Enum.map(conds, fn {k, expected} ->
      Map.fetch(obj, k)
      |> case do
        {:ok, v} -> expected == v
        _ -> false
      end
    end)
    |> Enum.all?()
  end

  def found?(%_{} = _obj, _conds, _found), do: false

  def make_left(list, _left, nil = _found), do: list
  def make_left(_list, left, found), do: [found | Enum.reverse(left)]
  def make_right(list, len, idx) when len != idx, do: Enum.take(list, idx - len)
  def make_right(_list, _len, _idx), do: []
end
