defmodule CacheStructTest do
  use ExUnit.Case

  alias ESC.Repo

  setup_all do
    Repo.init()
    :ok
  end

  test "get by conds ok" do
    ## first get
    {:ok, %User{id: uid1, name: _, role: %Role{id: rid1, name: _}}} = API.get_user(name: "not_exists_n1")

    assert_meta(User, 1)

    ## second get
    {:ok, %User{id: uid2, name: _, role: %Role{id: rid2, name: _}}} = API.get_user(name: "not_exists_n2")

    assert_meta(User, 2)

    ## verify
    assert uid1 != uid2
    assert rid1 != rid2

    ## n times
    1..3
    |> Enum.each(fn _ ->
      {:ok, %User{id: _, name: _, role: %Role{id: _, name: _}}} = API.get_user(id: uid1)
      assert_meta(User, 2)
    end)
  end

  test "get by id ok" do
    ## first get
    {:ok, %Role{id: rid1, name: _}} = API.get_role_by_id(name: "not_exists_n1")

    assert_meta(Role, 1)

    ## second get
    {:ok, %Role{id: rid2, name: _}} = API.get_role_by_id(name: "not_exists_n2")

    assert_meta(Role, 2)

    ## verify
    assert rid1 != rid2

    ## n times with different role ids
    1..3
    |> Enum.each(fn x ->
      {:ok, %Role{id: _, name: _}} = API.get_role_by_id(x)
      assert_meta(Role, 2 + x)
    end)

    ## n times with same role id
    1..3
    |> Enum.each(fn _ ->
      {:ok, %Role{id: _, name: _}} = API.get_role_by_id(rid1)
      assert_meta(Role, 5)
    end)
  end

  def assert_meta(module, expected_len) do
    repo = Repo.get_all()
    list = get_in(repo, [:db, module]) || []
    ids = get_in(repo, [:meta, :ids, module]) || []
    len = get_in(repo, [:meta, :len, module]) || 0
    assert expected_len == length(ids)
    assert expected_len == length(list)
    assert expected_len == len
  end
end
