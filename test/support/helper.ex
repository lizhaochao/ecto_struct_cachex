defmodule Helper do
  @moduledoc false
  def make_user do
    user_id = System.unique_integer([:positive]) * 99 + 98
    role_id = System.unique_integer([:positive]) * 98 + 97

    %User{
      id: user_id,
      name: "u_name#{user_id}",
      role: %Role{id: role_id, name: "r_name#{role_id}"}
    }
  end

  def make_role do
    role_id = System.unique_integer([:positive]) * 98 + 97
    %Role{id: role_id, name: "r_name#{role_id}"}
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
