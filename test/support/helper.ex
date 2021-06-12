defmodule Helper do
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
