defmodule ESC.Cache do
  @moduledoc false

  alias ESC.{LRU, Repo}

  ### Interface
  def get(struct_name, conds_or_id, exec_block) when is_atom(struct_name) do
    with(
      {list, len, cap} <- get_data(struct_name),
      {cached_obj, list} <- get_obj(list, conds_or_id, len),
      {:ok, obj} <- exec_block_if_needed(cached_obj, exec_block),
      [_ | _] <- save(struct_name, list, len, obj, cap, cached_obj)
    ) do
      {:ok, obj}
    else
      _ -> :get_obj_error
    end
  end

  def put(struct_name, exec_block) when is_atom(struct_name) do
    with(
      {:ok, %_{} = obj} <- exec_block.(),
      {list, len, cap} <- get_data(struct_name),
      [_ | _] <- save(struct_name, list, len, obj, cap)
    ) do
      {:ok, obj}
    else
      _ -> :put_obj_error
    end
  end

  ### Implements
  def get_data(struct_name) do
    fn repo ->
      list = get_in(repo, [:db, struct_name]) || []
      len = get_in(repo, [:meta, :len, struct_name]) || 0
      cap = get_in(repo, [:meta, :capacity, struct_name])
      {{list, len, cap}, repo}
    end
    |> Repo.get()
  end

  def get_obj([_ | _] = list, conds_or_id, len), do: LRU.get(list, conds_or_id, len)
  def get_obj(_other_list, _conds, _len), do: {nil, []}

  def exec_block_if_needed(nil = _obj, exec_block), do: exec_block.()
  def exec_block_if_needed(%_{} = obj, _exec_block), do: {:ok, obj}

  def save(struct_name, list, len, obj, cap, cached_obj \\ nil) do
    with(
      {_del_id, list} <- make_list(list, obj, cached_obj),
      len <- make_len(len, cap, cached_obj)
    ) do
      save(struct_name, list, len)
    end
  end

  def save(struct_name, list, len) do
    fn repo ->
      new_repo =
        repo
        |> put_in([:db, struct_name], list)
        |> put_in([:meta, :len, struct_name], len)

      {list, new_repo}
    end
    |> Repo.sync_update()
  end

  def make_list(list, obj, cached_obj \\ nil)
  def make_list(list, obj, nil = _cached_obj), do: LRU.put(list, obj)
  def make_list(list, _obj, _cached_obj), do: {nil, list}

  def make_len(len, cap, cached_obj \\ nil)
  def make_len(len, cap, nil = _cached_obj) when len != cap, do: len + 1
  def make_len(len, _cap, _cached_obj), do: len
end
