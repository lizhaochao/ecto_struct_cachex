defmodule ESC.LRU do
  @moduledoc false

  alias ESC.Core, as: Impl

  @empty_cond_idx 0
  @obj_at_top_idx 1
  @get_recursive_init_data {nil, 0, []}

  ### Interface
  def put(list, obj, len \\ nil, cap \\ nil)

  def put(list, %_{} = obj, nil = _len, nil = _cap)
      when is_list(list),
      do: add(obj, list)

  def put(list, %_{} = obj, len, cap)
      when is_list(list) and is_integer(len) and len >= 0 and is_integer(cap) and cap > 0,
      do: obj |> add(list) |> del_last(len, cap)

  def get(list, id, len)
      when is_list(list) and is_integer(id) and is_integer(len) and len >= 0,
      do: list |> get_by_conds({id}) |> make_result(list, len)

  def get(list, conds, len)
      when is_list(list) and is_list(conds) and is_integer(len) and len >= 0,
      do: list |> get_by_conds(conds) |> make_result(list, len)

  ### Implements Get
  def get_by_conds([] = _list, _conds), do: @get_recursive_init_data
  def get_by_conds(list, conds), do: do_get_by_conds(@get_recursive_init_data, list, conds)

  def do_get_by_conds({found, idx, _left}, list, [] = _conds), do: {found, idx, list}
  def do_get_by_conds({found, idx, left}, [] = _list, _conds), do: {found, idx, left}

  def do_get_by_conds({found, idx, left}, [%_{id: id} = obj | rest], {expected_id} = conds) do
    found? = expected_id == id
    break_or_continue({found, idx, left}, [%_{} = obj | rest], conds, found?)
  end

  def do_get_by_conds({found, idx, left}, [%_{} = obj | rest], conds) do
    found? = Impl.found?(obj, conds, found)
    break_or_continue({found, idx, left}, [%_{} = obj | rest], conds, found?)
  end

  def break_or_continue({found, idx, left}, [%_{} = obj | rest], conds, found?) do
    rest = if found?, do: [], else: rest
    idx = idx + 1

    found?
    |> if(do: {obj, idx, left}, else: {found, idx, [obj | left]})
    |> do_get_by_conds(rest, conds)
  end

  def make_result({_found, _idx, _left}, [] = list, 0 = _len), do: {nil, list}

  def make_result({found, idx, _left}, list, _len)
      when idx in [@empty_cond_idx, @obj_at_top_idx],
      do: {found, list}

  def make_result({found, idx, left}, list, len)
      when len == idx,
      do: {found, Impl.make_left(list, left, found)}

  def make_result({found, idx, left}, list, len) do
    new_list = Impl.make_left(list, left, found) ++ Impl.make_right(list, idx, len)
    {found, new_list}
  end

  ### Implements Put
  def add(obj, list), do: {nil, [obj | list]}

  def del_last({_del_id, list}, len, cap) when len == cap do
    with(
      l <- Enum.reverse(list),
      %{id: del_id} <- hd(l)
    ) do
      {del_id, Enum.reverse(tl(l))}
    end
  end

  def del_last({_del_id, list}, _len, _cap), do: {nil, list}
end
