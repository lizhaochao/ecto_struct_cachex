defmodule ESC.KVRepo do
  @moduledoc false

  alias ESC.KVRepo.Server

  ###
  def sync_update(fun), do: GenServer.call(Server, {:update, fun})
  def update(fun), do: GenServer.cast(Server, {:update, fun})

  ###
  def init, do: GenServer.call(Server, :init)
  def get_repo, do: GenServer.call(Server, :get_repo)
end

defmodule ESC.KVRepo.Server do
  @moduledoc false

  use GenServer

  @init_repo %{
    db: %{},
    meta: %{
      tables: MapSet.new(),
      anti_refs: %{},
      ids: %{},
      capacity: %{},
      len: %{},
      gc: %{
        counts: %{},
        shards: %{}
      }
    }
  }

  def start_link(opts) when is_list(opts) do
    with(
      impl_m <- __MODULE__,
      repo_name <- impl_m,
      name_opt <- [name: repo_name]
    ) do
      GenServer.start_link(impl_m, :ok, opts ++ name_opt)
    end
  end

  @impl true
  def init(:ok), do: {:ok, @init_repo}

  ## sync
  @impl true
  def handle_call(:init, _from, _repo) do
    new_repo = @init_repo
    {:reply, new_repo, new_repo}
  end

  @impl true
  def handle_call(:get_repo, _from, repo), do: {:reply, repo, repo}

  @impl true
  def handle_call({:update, fun}, _from, repo) do
    {value, new_repo} = fun.(repo)
    {:reply, value, new_repo}
  end

  ## async
  @impl true
  def handle_cast({:update, fun}, repo) do
    new_repo = fun.(repo)
    {:noreply, new_repo}
  end
end
