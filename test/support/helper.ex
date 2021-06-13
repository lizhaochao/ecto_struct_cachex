defmodule Helper do
  @moduledoc false
  def make_user do
    user_id = System.unique_integer([:positive])
    role_id = System.unique_integer([:positive])

    %User{
      id: user_id,
      name: "u_name#{user_id}",
      role: %Role{id: role_id, name: "r_name#{role_id}"},
      parent: %Parent{id: 1, name: "parent", child: %Child{id: 2}}
    }
  end

  def make_role do
    role_id = System.unique_integer([:positive])
    %Role{id: role_id, name: "r_name#{role_id}", child: %Child{id: 2}}
  end
end

defmodule CacheDecorator do
  @moduledoc false
  use ESC
end

defmodule API do
  @moduledoc false
  use CacheDecorator

  @decorate cache_put(User)
  def create_user(id, name) do
    {id, name}
    user = Helper.make_user()
    {:ok, user}
  end

  @decorate cache_put(Role)
  def create_role(id, name) do
    {id, name}
    role = Helper.make_role()
    {:ok, role}
  end

  @decorate cache_evict(User)
  def delete_user(conds_or_id) do
    {conds_or_id}
    :ok
  end

  @decorate cache_evict(User)
  def update_user(conds) do
    {conds}
    :ok
  end

  @decorate cache_evict(Role)
  def delete_role(conds_or_id) do
    {conds_or_id}
    :ok
  end

  @decorate cache_evict(Role)
  def update_role(conds) do
    {conds}
    :ok
  end

  @decorate cache_object(User)
  def get_user(conds) do
    {conds}
    user = Helper.make_user()
    {:ok, user}
  end

  @decorate cache_object(Role)
  def get_role_by_id(id) do
    {id}
    user = Helper.make_role()
    {:ok, user}
  end
end
