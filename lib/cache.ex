defmodule ESC.Cache do
  @moduledoc false

  alias ESC.{Config, Core, LRU, Repo}

  ### Interface
  def get(struct_name, conds_or_id, exec_block) when is_atom(struct_name) do
    with(
      {list, len, ids, cap} <- get_data(struct_name),
      {cached_obj, list} <- get_obj(list, conds_or_id, len),
      {:ok, obj} <- exec_block_if_needed(cached_obj, exec_block),
      [_ | _] <- save(struct_name, list, len, ids, cap, obj, cached_obj)
    ) do
      {:ok, obj}
    else
      _ -> :get_obj_error
    end
  end

  def put(struct_name, exec_block) when is_atom(struct_name) do
    with(
      {:ok, %_{} = obj} <- exec_block.(),
      {list, len, ids, cap} <- get_data(struct_name),
      {list, len, ids} <- del_if_exists(list, len, obj, ids),
      [_ | _] <- save(struct_name, list, len, ids, cap, obj)
    ) do
      {:ok, obj}
    else
      _ -> :put_obj_error
    end
  end

  def delete(struct_name, conds_or_id, exec_block) when is_atom(struct_name) do
    with(
      :ok <- exec_block.(),
      {list, len, ids, _cap} <- get_data(struct_name),
      {cached_obj, list} <- get_obj(list, conds_or_id, len),
      {list, len, ids} <- del_if_exists(list, len, cached_obj, ids),
      list when is_list(list) <- save_delete(list, len, ids, struct_name, conds_or_id)
    ) do
      :ok
    else
      _ -> :delete_obj_error
    end
  end

  ### Implements
  def save_delete(list, len, ids, struct_name, struct_id) do
    fn repo ->
      new_repo =
        repo
        |> delete_table_data(struct_name, struct_id)
        |> Enum.concat([{struct_name, list, len, ids}])
        |> Enum.reduce(repo, fn {name, list, len, ids}, repo ->
          repo
          |> put_in([:db, name], list)
          |> put_in([:meta, :len, name], len)
          |> put_in([:meta, :ids, name], ids)
        end)

      {list, new_repo}
    end
    |> Repo.sync_update()
  end
  def delete_table_data(repo, struct_name, struct_id) do
    with(
      back_refs when not is_nil(back_refs) <- get_in(repo, [:meta, :back_refs, struct_name]),
      tables <- MapSet.to_list(back_refs),
      table_data <- Map.get(repo, :db) |> Map.take(tables)
    ) do
      Enum.map(tables, fn table ->
        Map.get(table_data, table, [])
        |> delete_by_struct(table, struct_name, struct_id, repo)
      end)
    else
      _ -> []
    end
  end
  def delete_by_struct(list, table, struct_name, struct_id, repo) do
    with(
      {del_ids, new_list} <- Core.delete_by_struct(list, struct_name, struct_id),
      #
      del_len <- length(del_ids),
      len <- get_in(repo, [:meta, :len, table]) || 0,
      len <- len - del_len,
      new_len <- if(len < 0, do: 0, else: len),
      #
      ids <- get_in(repo, [:meta, :ids, table]) || [],
      new_ids <- if(ids == [], do: [], else: ids -- del_ids)
    ) do
      {table, new_list, new_len, new_ids}
    end
  end

  #
  def get_data(struct_name) do
    default_cap = Config.get_default_capacity()

    fn repo ->
      list = get_in(repo, [:db, struct_name]) || []
      len = get_in(repo, [:meta, :len, struct_name]) || 0
      ids = get_in(repo, [:meta, :ids, struct_name]) || []
      cap = get_in(repo, [:meta, :capacity, struct_name]) || default_cap
      {{list, len, ids, cap}, repo}
    end
    |> Repo.get()
  end

  def get_obj([_ | _] = list, conds_or_id, len), do: LRU.get(list, conds_or_id, len)
  def get_obj(_other_list, _conds, _len), do: {nil, []}

  def exec_block_if_needed(nil = _obj, exec_block), do: exec_block.()
  def exec_block_if_needed(%_{} = obj, _exec_block), do: {:ok, obj}

  def del_if_exists(list, len, nil = _obj, ids), do: {list, len, ids}
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

  def save(struct_name, list, len, ids, cap, obj, cached_obj \\ nil) do
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
      tables = make_tables(repo, ids, struct_name)
      back_refs = make_back_refs(repo, ids, list)

      new_repo =
        repo
        |> put_in([:db, struct_name], list)
        |> put_in([:meta, :len, struct_name], len)
        |> put_in([:meta, :ids, struct_name], ids)
        |> put_in_if_not_nil([:meta, :tables], tables)
        |> put_in_if_not_nil([:meta, :back_refs], back_refs)

      {list, new_repo}
    end
    |> Repo.sync_update()
  end

  def make_list(list, obj, len, cap, cached_obj \\ nil)
  def make_list(list, obj, len, cap, nil = _cached_obj), do: LRU.put(list, obj, len, cap)
  def make_list(list, _obj, _len, _cap, _cached_obj), do: {nil, list}

  def make_ids(ids, id, del_id, cached_obj), do: ids |> add_id(id, cached_obj) |> del_id(del_id)
  def add_id(ids, id, nil = _cached_obj), do: ESCList.radd(ids, id)
  def add_id(ids, _id, _cached_obj), do: ids
  def del_id(ids, nil = _id), do: ids
  def del_id(ids, id), do: ESCList.del(ids, id)

  def make_len(len, cap, cached_obj \\ nil)
  def make_len(len, cap, nil = _cached_obj) when len != cap, do: len + 1
  def make_len(len, _cap, _cached_obj), do: len

  def make_tables(repo, ids, struct_name) do
    repo |> get_in([:meta, :tables]) |> do_make_tables(ids, struct_name)
  end
  def do_make_tables(tables, [_] = _ids, struct_name), do: put_if_not_exists(tables, struct_name)
  def do_make_tables(_tables, _ids, _struct_name), do: nil

  def make_back_refs(repo, ids, [obj | _] = _list), do: get_in(repo, [:meta, :back_refs]) |> do_make_back_refs(ids, obj)
  def do_make_back_refs(back_refs, [_] = _ids, obj), do: Core.get_refs(obj) |> reduce_back_refs(back_refs)
  def do_make_back_refs(_back_refs, _ids, _obj), do: nil
  def reduce_back_refs({:ok, {struct_name, refs}}, back_refs) do
    Enum.reduce(refs, back_refs, fn ref, back_refs ->
      refs = Map.get(back_refs, ref, %MapSet{}) |> MapSet.put(struct_name)
      Map.put(back_refs, ref, refs)
    end)
  end
  def reduce_back_refs(_other_refs, _back_refs), do: nil

  def put_in_if_not_nil(data, path, val), do: (val && put_in(data, path, val)) || data
  def put_if_not_exists(set, val), do: (val not in set && MapSet.put(set, val)) || nil
end
