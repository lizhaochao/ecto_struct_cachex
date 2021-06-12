defmodule EctoStructCachex.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [ESC.KVRepo.Server]
    opts = [strategy: :one_for_one, name: EctoStructCachex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
