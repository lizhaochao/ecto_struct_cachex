defmodule ESC.Core do
  @moduledoc false

  ### Interface Delete
  def delete_by_struct(list, struct_name, struct_id)
      when is_list(list) and is_atom(struct_name) and is_integer(struct_id) do
    traverse(list, struct_name, struct_id)
  end

  ### Implements Delete
  def traverse(list, struct_name, struct_id),
    do: do_traverse(list, struct_name, struct_id, [])

  def do_traverse([] = _list, _struct_name, _struct_id, new_list),
    do: Enum.reverse(new_list)

  def do_traverse([%_{} = obj | rest], struct_name, struct_id, new_list) do
    with(
      should_delete? <- should_delete?(obj, struct_name, struct_id),
      new_list <- if(should_delete?, do: new_list, else: [obj | new_list])
    ) do
      do_traverse(rest, struct_name, struct_id, new_list)
    end
  end

  def should_delete?(%{} = obj, struct_name, struct_id) do
    obj
    |> Map.from_struct()
    |> Keyword.new()
    |> should_delete?(struct_name, struct_id, false)
  end

  def should_delete?([] = _obj, _struct_name, _struct_id, should?), do: should?

  def should_delete?([{_k, %_{} = obj} | rest], struct_name, struct_id, _should?) do
    should? = obj_should_delete?(obj, struct_name, struct_id)
    rest = if should?, do: [], else: rest
    should_delete?(rest, struct_name, struct_id, should?)
  end

  def should_delete?([{_k, [%_{} = _obj | _rest] = v} | rest], struct_name, struct_id, _should?) do
    should? =
      Enum.map(v, fn nested_obj ->
        obj_should_delete?(nested_obj, struct_name, struct_id)
      end)
      |> Enum.any?()

    should_delete?(rest, struct_name, struct_id, should?)
  end

  def should_delete?([{_k, _v} | rest], struct_name, struct_id, should?) do
    should_delete?(rest, struct_name, struct_id, should?)
  end

  def obj_should_delete?(%{__struct__: struct, id: id}, struct_name, struct_id)
      when id == struct_id and struct == struct_name,
      do: true

  def obj_should_delete?(%_{}, _struct_name, _struct_id), do: false
end
