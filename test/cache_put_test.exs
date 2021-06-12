defmodule CachePutTest do
  use ExUnit.Case

  alias ESC.Repo

  setup_all do
    Repo.init()
    :ok
  end

  test "create ok" do
    ## first get
    {:ok, %User{id: uid1, role: %Role{id: rid1}}} = API.create_user(1, "name1")
    assert_meta(User, 1)

    ## second get
    {:ok, %User{id: uid2, role: %Role{id: rid2}}} = API.create_user(2, "name2")
    assert_meta(User, 2)

    ## verify
    assert uid1 != uid2
    assert rid1 != rid2

    ## n times create
    1..3
    |> Enum.each(fn x ->
      fake_id = 3
      fake_name = "name3"
      {:ok, %User{role: %Role{}}} = API.create_user(fake_id, fake_name)
      assert_meta(User, 2 + x)
    end)

    ## n times get
    1..3
    |> Enum.each(fn _ ->
      {:ok, %User{id: _, name: _, role: %Role{id: _, name: _}}} = API.get_user(id: uid1)
      assert_meta(User, 5)
    end)
  end

  def assert_meta(module, expected_len) do
    repo1 = Repo.get_all()
    users1 = get_in(repo1, [:db, module])
    user_len1 = get_in(repo1, [:meta, :len, module])
    assert length(users1) == user_len1
    assert expected_len == user_len1
  end
end
