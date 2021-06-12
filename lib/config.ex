defmodule ESC.Config do
  @moduledoc false

  @default_capacity 160_203

  def get_default_capacity,
    do: Application.get_env(:ecto_struct_cachex, :capacity, @default_capacity)
end
