defmodule CachePutTest do
  use ExUnit.Case

  alias ESC.{Config, Repo}

  setup do
    Repo.init()
    :ok
  end

  @unused_id 3
  @unused_name "name3"

  test "create ok" do
    ## first get
    {:ok, %User{id: uid1, role: %Role{id: rid1}}} = API.create_user(@unused_id, @unused_name)
    assert_meta(User, 1)

    ## second get
    {:ok, %User{id: uid2, role: %Role{id: rid2}}} = API.create_user(@unused_id, @unused_name)
    assert_meta(User, 2)

    ## verify
    assert uid1 != uid2
    assert rid1 != rid2

    ## n times create
    1..3
    |> Enum.each(fn x ->
      {:ok, %User{role: %Role{}}} = API.create_user(@unused_id, @unused_name)
      assert_meta(User, 2 + x)
    end)

    ## n times get
    1..3
    |> Enum.each(fn _ ->
      {:ok, %User{id: _, name: _, role: %Role{id: _, name: _}}} = API.get_user(id: uid1)
      assert_meta(User, 5)
    end)
  end

  test "lru with capacity ok" do
    capacity = Config.get_default_capacity()

    ## n times create
    1..capacity
    |> Enum.each(fn x ->
      {:ok, %User{role: %Role{}}} = API.create_user(@unused_id, @unused_name)
      assert_meta(User, x)
    end)

    ## n times create, up to capacity
    1..10
    |> Enum.each(fn _ ->
      {:ok, %User{role: %Role{}}} = API.create_user(@unused_id, @unused_name)
      assert_meta(User, capacity)
    end)
  end

  test "meta tables" do
    1..3
    |> Enum.each(fn _ ->
      {:ok, %User{id: uid1, role: %Role{}}} = API.create_user(@unused_id, @unused_name)
      {:ok, %User{role: %Role{}}} = API.get_user(id: uid1)
      {:ok, %Role{id: rid1}} = API.create_role(@unused_id, @unused_name)
      {:ok, %Role{}} = API.get_role_by_id(rid1)
    end)

    repo = Repo.get_all()
    tables = get_in(repo, [:meta, :tables])
    assert 2 == length(MapSet.to_list(tables))
  end

  def assert_meta(module, expected_len) do
    repo = Repo.get_all()
    list = get_in(repo, [:db, module])
    ids = get_in(repo, [:meta, :ids, module])
    len = get_in(repo, [:meta, :len, module])
    assert expected_len == length(ids)
    assert expected_len == length(list)
    assert expected_len == len
  end
end
