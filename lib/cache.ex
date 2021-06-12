defmodule ESC.Cache do
  @moduledoc false

  alias ESC.{Config, Core, LRU, Repo}

  ### Interface
  def get(struct_name, conds_or_id, exec_block) when is_atom(struct_name) do
    with(
      default_capacity <- Config.get_default_capacity(),
      {list, len, cap, ids} <- get_data(struct_name, default_capacity),
      {cached_obj, list} <- get_obj(list, conds_or_id, len),
      {:ok, obj} <- exec_block_if_needed(cached_obj, exec_block),
      [_ | _] <- save(struct_name, list, len, obj, cap, ids, cached_obj)
    ) do
      {:ok, obj}
    else
      _ -> :get_obj_error
    end
  end

  def put(struct_name, exec_block) when is_atom(struct_name) do
    with(
      {:ok, %_{} = obj} <- exec_block.(),
      default_capacity <- Config.get_default_capacity(),
      {list, len, cap, ids} <- get_data(struct_name, default_capacity),
      {list, len, ids} <- del_if_exists(list, len, obj, ids),
      [_ | _] <- save(struct_name, list, len, obj, cap, ids)
    ) do
      {:ok, obj}
    else
      _ -> :put_obj_error
    end
  end

  ### Implements
  def get_data(struct_name, default_capacity) do
    fn repo ->
      list = get_in(repo, [:db, struct_name]) || []
      len = get_in(repo, [:meta, :len, struct_name]) || 0
      cap = get_in(repo, [:meta, :capacity, struct_name]) || default_capacity
      ids = get_in(repo, [:meta, :ids, struct_name]) || []
      {{list, len, cap, ids}, repo}
    end
    |> Repo.get()
  end

  def get_obj([_ | _] = list, conds_or_id, len), do: LRU.get(list, conds_or_id, len)
  def get_obj(_other_list, _conds, _len), do: {nil, []}

  def exec_block_if_needed(nil = _obj, exec_block), do: exec_block.()
  def exec_block_if_needed(%_{} = obj, _exec_block), do: {:ok, obj}

  def del_if_exists(list, len, %{id: id} = _obj, ids) do
    ids
    |> ESCList.exists?(id)
    |> if(
      do:
        (
          list = Core.delete(list, id, len)
          len = len - 1
          ids = ESCList.del(ids, id)
          {list, len, ids}
        ),
      else: {list, len, ids}
    )
  end

  def save(struct_name, list, len, obj, cap, ids, cached_obj \\ nil) do
    with(
      %{id: id} <- obj,
      {del_id, list} <- make_list(list, obj, len, cap, cached_obj),
      ids <- make_ids(ids, id, del_id, cached_obj),
      len <- make_len(len, cap, cached_obj)
    ) do
      save(struct_name, list, len, ids)
    end
  end

  def save(struct_name, list, len, ids) do
    fn repo ->
      new_repo =
        repo
        |> put_in([:db, struct_name], list)
        |> put_in([:meta, :len, struct_name], len)
        |> put_in([:meta, :ids, struct_name], ids)

      {list, new_repo}
    end
    |> Repo.sync_update()
  end

  def make_list(list, obj, len, cap, cached_obj \\ nil)
  def make_list(list, obj, len, cap, nil = _cached_obj), do: LRU.put(list, obj, len, cap)
  def make_list(list, _obj, _len, _cap, _cached_obj), do: {nil, list}

  def make_ids(ids, id, del_id, cached_obj), do: ids |> add_id(id, cached_obj) |> del_id(del_id)
  def del_id(ids, nil = _id), do: ids
  def del_id(ids, id), do: ESCList.del(ids, id)
  def add_id(ids, id, nil = _cached_obj), do: ESCList.radd(ids, id)
  def add_id(ids, _id, _cached_obj), do: ids

  def make_len(len, cap, cached_obj \\ nil)
  def make_len(len, cap, nil = _cached_obj) when len != cap, do: len + 1
  def make_len(len, _cap, _cached_obj), do: len
end
