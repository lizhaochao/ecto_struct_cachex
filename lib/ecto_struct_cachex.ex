defmodule ESC do
  @moduledoc """
  ## Sample
  This Sample Project is the basis for ecto_struct_cachex, help you use well.

  Download via [Gitee](https://gitee.com/lizhaochao/ecto_struct_cachex_sample) or [Github](https://github.com/lizhaochao/ecto_struct_cachex_sample).

  ## Problems Solving

  - **Support getting struct by keyword from cache.**

  ```elixir
  # define Cache by using ESC (ecto_struct_cachex)
  defmodule StructCache do
    use ESC
    # reformat resp by post_hook callback.
    def post_hook(resp), do: resp
  end

  # use StructCache to inject cache_struct/1, cache_put/1, cache_evict/1 decorators.
  defmodule API do
    use StructCache
    @decorate cache_struct(User)
    def get_user(conds) do
      ...
      {:ok, user}
    end
  end

  # pass keyword to get object.
  API.get_user([name: "name", addr: "addr"])
  ```

  -  **Delete dirty structs when its deep nested struct updated/deleted.**

  ```elixir
  %{
    User => [
      %User{
        id: 1,
        user_name: "u_name",
        role: %Role{id: 2, role_name: "r_name2"}
      }
    ],
    Role => [
      %Role{id: 1, role_name: "r_name1"},
      %Role{id: 2, role_name: "r_name2"}
    ]
  }
  ```
  For above sample data, **role** `id=2`  struct deleted/updated, **user** `id=1` struct will be deleted too.

  ## Cache based on LRU algorithm.
  ### Benchmark
  ```bash
  mix bench
  benchmark name                  iterations   average time
  only put                         100000000   0.09 µs/op
  get - empty cond                  10000000   0.15 µs/op
  put - should remove               10000000   0.23 µs/op
  get - by id - obj at top          10000000   0.27 µs/op
  get - by conds - obj at top       10000000   0.58 µs/op
  get - by conds - obj at mid        1000000   1.71 µs/op
  get - by conds - obj at bottom     1000000   2.21 µs/op
  ```
  """

  defmacro __using__(opts) do
    quote do
      use Decorator.Define, cache_struct: 1, cache_put: 1, cache_evict: 1
      use ESC.Decorator.CacheStruct, unquote(opts)
      use ESC.Decorator.CachePut, unquote(opts)
      use ESC.Decorator.CacheEvict, unquote(opts)
    end
  end
end
