defmodule ESC do
  @moduledoc """
  ## Sample
  This Sample Project is the basis for ecto_struct_cachex, help you use well.

  Download via [Gitee](https://gitee.com/lizhaochao/ecto_struct_cachex_sample) or [Github](https://github.com/lizhaochao/ecto_struct_cachex_sample).

  ## Problem Solving

  - **Support get struct by keyword from cache.**

  ```elixir
  defmodule API do
    @decorate cache_object(User)
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
  %User{
    id: 1,
    user_name: "u_name",
    role: %Role{id: 2, role_name: "r_name"}
  }
  ```
  For above sample struct, role struct deleted/upadted, user struct will be deleted too.

  ## Benchmark
  ```bash
  mix bench
  ## LRUBench
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
      use Decorator.Define, cache_object: 1, cache_put: 1, cache_evict: 1
      use ESC.Decorator.CacheObject, unquote(opts)
      use ESC.Decorator.CachePut, unquote(opts)
      use ESC.Decorator.CacheEvict, unquote(opts)
    end
  end
end
