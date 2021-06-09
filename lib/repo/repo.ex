defmodule ESC.Repo do
  @moduledoc false
end

defmodule ESC.Repo.Operation do
  @moduledoc false

  #  def select(opts \\ []) do
  #    {where, or_where} = get_wheres(opts)
  #    table = opts |> Keyword.get(:from, nil)
  #    fields = opts |> Keyword.get(:fields, nil)
  #
  #    fun = fn state ->
  #      filter(state, table, where, or_where, fields, &Enum.filter/2)
  #    end
  #
  #    opts |> Keyword.put(:fun, fun)
  #  end
  #
  #  def all(opts) do
  #    fun = opts |> Keyword.get(:fun, fn state -> state end)
  #
  #    @memory_name
  #    |> Memory.get(fun)
  #    |> post_all(opts)
  #  end
  #
  #  def post_all(records, opts) do
  #    order_by = opts |> Keyword.get(:order_by, [])
  #    offset = opts |> Keyword.get(:offset, 0)
  #    limit = opts |> Keyword.get(:limit, nil)
  #
  #    records
  #    |> sort(order_by)
  #    |> limit(limit, offset)
  #  end
  #
  #  defp get_wheres(opts) do
  #    or_where = opts |> Keyword.get(:or_where, [])
  #    where = opts |> Keyword.get(:where, [])
  #    {where, or_where}
  #  end
  #
  #  defp filter(state, table, where, or_where, fields, fun) do
  #    table_data = (table && (state |> _get_in([table]) || [])) || state
  #    filter_data = table_data |> do_filter(where, or_where, fun)
  #
  #    take_data =
  #      fields &&
  #        filter_data
  #        |> Enum.map(fn record ->
  #          record |> Map.take(fields)
  #        end)
  #
  #    take_data || filter_data
  #  end
  #
  #  defp do_filter(records, [], [], _fun) do
  #    records
  #  end
  #
  #  defp do_filter(records, [_ | _] = where_opts, [], fun) do
  #    records |> do_filter(where_opts, fun)
  #  end
  #
  #  defp do_filter(records, [], [_ | _] = or_where_opts, fun) do
  #    records |> do_filter(or_where_opts, fun)
  #  end
  #
  #  defp do_filter(records, [_ | _] = where_opts, [_ | _] = or_where_opts, fun) do
  #    where_records = records |> do_filter(where_opts, fun)
  #
  #    records
  #    |> do_filter(or_where_opts, fun)
  #    |> Enum.concat(where_records)
  #    |> MapSet.new()
  #    |> MapSet.to_list()
  #  end
  #
  #  defp do_filter(records, opts, fun) when is_list(records) and is_list(opts) do
  #    @rules
  #    |> Enum.reduce(records, fn rule, acc ->
  #      acc |> filter_by_rules(opts, rule, fun)
  #    end)
  #  end
  #
  #  defp do_filter(records, _conds, _fun) do
  #    records
  #  end
  #
  #  defp reduce_results(conds, record, rule) when is_atom(rule) do
  #    conds
  #    |> Enum.reduce([], fn {k, v}, acc ->
  #      ok? = record |> Map.get(k) |> rule(v, rule)
  #      [ok? | acc]
  #    end)
  #  end
  #
  #  defp reduce_results(_conds, _record, _rule) do
  #    [true]
  #  end
  #
  #  ###
  #  def insert(into: table, value: value) do
  #    fun = do_insert(into: table, value: value)
  #    @memory_name |> Memory.get_and_update(fun) |> as_ok()
  #  end
  #
  #  def do_insert(into: table, value: value) do
  #    fn state ->
  #      records = _get_in(state, [table]) || []
  #      record = Map.put(value, :id, gen_id(records))
  #      new_state = state |> _put_in([table], [record | records])
  #      {record, new_state}
  #    end
  #  end
  #
  #  def insert_all(into: _table, values: []) do
  #    :ok
  #  end
  #
  #  def insert_all(into: table, values: [value | rest]) do
  #    insert(into: table, value: value)
  #    |> case do
  #      {:ok, %{}} -> insert_all(into: table, values: rest)
  #      _ -> :error
  #    end
  #  end
  #
  #  ###
  #  def update(table, opts: opts, values: values) do
  #    fun = do_update(table, opts: opts, values: values)
  #    @memory_name |> Memory.get_and_update(fun)
  #  end
  #
  #  def do_update(table, opts: opts, values: values) do
  #    {where, or_where} = get_wheres(opts)
  #
  #    do_filter = fn record ->
  #      if do_filter([record], where, or_where, &Enum.filter/2) == [] do
  #        record
  #      else
  #        values2 = values |> Enum.into(%{}) |> Map.drop([:id])
  #        record |> Map.merge(values2)
  #      end
  #    end
  #
  #    fn state ->
  #      updated =
  #        state
  #        |> filter(table, [], [], nil, &Enum.filter/2)
  #        |> Enum.map(fn record ->
  #          do_filter.(record)
  #        end)
  #
  #      new_state = _put_in(state, [table], updated)
  #      {:ok, new_state}
  #    end
  #  end
  #
  #  ###
  #  def delete(from: table, opts: opts) do
  #    fun = do_delete(from: table, opts: opts)
  #    @memory_name |> Memory.get_and_update(fun)
  #  end
  #
  #  def do_delete(from: table, opts: opts) do
  #    {where, or_where} = get_wheres(opts)
  #
  #    fn state ->
  #      updated = filter(state, table, where, or_where, nil, &Enum.reject/2)
  #      new_state = _put_in(state, [table], updated)
  #      {:ok, new_state}
  #    end
  #  end
  #
  #  ###
  #  def truncate(table) do
  #    fun = do_truncate(table)
  #    @memory_name |> Memory.get_and_update(fun)
  #  end
  #
  #  def do_truncate(table) do
  #    fn state ->
  #      data = state |> _get_in([table])
  #      new_state = (data && _put_in(state, [table], [])) || state
  #      {:ok, new_state}
  #    end
  #  end
  #
  #  def drop do
  #    fun = do_drop()
  #    @memory_name |> Memory.update(fun)
  #  end
  #
  #  def do_drop do
  #    fn _ ->  @init_data end
  #  end
end
