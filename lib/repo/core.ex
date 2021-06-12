defmodule ESC.Core do
  @moduledoc false

  @del_recursive_init_data {0, []}

  ### Interface
  def delete_by_struct(list, struct_name, struct_id)
      when is_list(list) and is_atom(struct_name) and is_integer(struct_id) do
    traverse_kv(list, struct_name, struct_id)
  end

  def delete(list, id, len)
      when is_list(list) and is_integer(id) and is_integer(len) and len >= 0,
      do: list |> del_by_conds({id}) |> make_del_result(list, len)

  def delete(list, conds, len)
      when is_list(list) and is_list(conds) and is_integer(len) and len >= 0,
      do: list |> del_by_conds(conds) |> make_del_result(list, len)

  ### Implements Delete
  def del_by_conds([] = _list, _conds), do: @del_recursive_init_data
  def del_by_conds(list, conds), do: do_del_by_conds(list, conds, @del_recursive_init_data)

  def do_del_by_conds(list, [] = _conds, {idx, _left}), do: {idx, list}
  def do_del_by_conds([] = _list, _conds, {idx, left}), do: {idx, Enum.reverse(left)}

  def do_del_by_conds([%_{id: id} = obj | rest], {expected_id} = conds, {idx, left}) do
    with(
      found? <- expected_id == id,
      left <- if(found?, do: left, else: [obj | left]),
      idx <- idx + 1,
      rest <- if(found?, do: [], else: rest)
    ) do
      do_del_by_conds(rest, conds, {idx, left})
    end
  end

  def do_del_by_conds([%_{} = obj | rest], conds, {idx, left}) do
    with(
      found? <- found?(obj, conds),
      left <- if(found?, do: left, else: [obj | left]),
      idx <- idx + 1
    ) do
      do_del_by_conds(rest, conds, {idx, left})
    end
  end

  def make_del_result({idx, left}, list, len), do: left ++ make_right(list, idx, len)

  ### Implements Delete By Struct
  def traverse_kv(list, struct_name, struct_id),
    do: do_traverse_kv(list, struct_name, struct_id, [])

  def do_traverse_kv([] = _list, _struct_name, _struct_id, new_list),
    do: Enum.reverse(new_list)

  def do_traverse_kv([%_{} = obj | rest], struct_name, struct_id, new_list) do
    with(
      del? when is_atom(del?) <- drill_down_del?(obj, struct_name, struct_id),
      new_list <- if(del?, do: new_list, else: [obj | new_list])
    ) do
      do_traverse_kv(rest, struct_name, struct_id, new_list)
    end
  end

  def drill_down_del?(%_{} = obj, struct_name, struct_id) do
    obj
    |> Map.from_struct()
    |> Keyword.new()
    |> del?(struct_name, struct_id, false)
  end

  def del?([] = _obj, _struct_name, _struct_id, should?), do: should?

  def del?([{_k, %_{} = obj} | rest], struct_name, struct_id, _should?) do
    should? =
      obj_del?(obj, struct_name, struct_id)
      |> if(
        do: del?(rest, struct_name, struct_id, true),
        else: drill_down_del?(obj, struct_name, struct_id)
      )

    del?(rest, struct_name, struct_id, should?)
  end

  def del?([{_k, [%_{} | _] = objs} | rest], struct_name, struct_id, _should?) do
    should? =
      objs_del?(objs, struct_name, struct_id)
      |> if(
        do: del?(rest, struct_name, struct_id, true),
        else: objs -- traverse_kv(objs, struct_name, struct_id) != []
      )

    del?(rest, struct_name, struct_id, should?)
  end

  def del?([{_k, _v} | rest], struct_name, struct_id, should?) do
    del?(rest, struct_name, struct_id, should?)
  end

  def objs_del?(objs, struct_name, struct_id) do
    objs
    |> Enum.map(fn obj -> obj_del?(obj, struct_name, struct_id) end)
    |> Enum.any?()
  end

  def obj_del?(%{__struct__: struct, id: id}, struct_name, struct_id)
      when id == struct_id and struct == struct_name,
      do: true

  def obj_del?(%_{}, _struct_name, _struct_id), do: false

  ###
  def found?(obj, conds, found \\ nil)

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

  def make_right(list, idx, len) when len != idx, do: Enum.take(list, idx - len)
  def make_right(_list, _idx, _len), do: []
end
