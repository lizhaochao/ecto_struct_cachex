defmodule CacheEvictTest do
  use ExUnit.Case

  alias ESC.Repo

  setup do
    Repo.init()
    :ok
  end

  @unused_id 3
  @unused_name "name3"

  test "delete ok" do
    {:ok, %User{id: uid1}} = API.create_user(@unused_id, @unused_name)
    assert_meta(User, 1)

    Enum.each(1..3, fn _ ->
      :ok = API.delete_user(uid1)
      assert_meta(User, 0)
    end)
  end

  test "update ok" do
    {:ok, %User{id: uid1}} = API.create_user(@unused_id, @unused_name)
    assert_meta(User, 1)

    Enum.each(1..3, fn _ ->
      :ok = API.update_user(id: uid1)
      assert_meta(User, 0)
    end)
  end

  test "not found obj" do
    {:ok, %User{}} = API.create_user(@unused_id, @unused_name)
    assert_meta(User, 1)

    Enum.each(1..3, fn _ ->
      :ok = API.update_user(id: "any id")
      assert_meta(User, 1)
    end)

    Enum.each(1..3, fn _ ->
      :ok = API.delete_user(id: "any id")
      assert_meta(User, 1)
    end)
  end

  test "delete back data" do
    assert_meta(Role, 0)
    assert_meta(User, 0)

    1..3
    |> Enum.map(fn n ->
      {:ok, %User{role: %Role{id: rid}}} = API.create_user(@unused_id, @unused_name)
      assert_meta(User, n)
      rid
    end)
    |> Enum.each(fn rid ->
      :ok = API.delete_role(rid)
    end)

    assert_meta(Role, 0)
    assert_meta(User, 0)
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
