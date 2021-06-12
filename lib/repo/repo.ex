defmodule ESC.Repo do
  @moduledoc false

  alias ESC.KVRepo

  ###
  def get(fun) when is_function(fun), do: KVRepo.sync_update(fun)
  def sync_update(fun) when is_function(fun), do: KVRepo.sync_update(fun)
  def update(fun) when is_function(fun), do: KVRepo.update(fun)

  ###
  def init, do: KVRepo.init()
  def get_all, do: KVRepo.get_repo()
end
