defmodule ESC.Core do
  @moduledoc false

  ### Interface
  def delete_by_struct(list, struct_name, struct_id)
      when is_list(list) and is_atom(struct_name) and is_integer(struct_id) do
    traverse_kv(list, struct_name, struct_id)
  end

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
end
