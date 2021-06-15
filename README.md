# ecto_struct_cachex  [![Hex Version](https://img.shields.io/hexpm/v/ecto_struct_cachex.svg)](https://hex.pm/packages/ecto_struct_cachex) [![docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/ecto_struct_cachex/)
in-memory cache for ecto struct.
## Installation
Add ecto_struct_cachex to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [{:ecto_struct_cachex, "~> 0.2.5"}]
end
```
run `mix deps.get`.

## Sample
This Sample Project is the basis for ecto_struct_cachex, help you use well. 

Download via [Gitee](https://gitee.com/lizhaochao/ecto_struct_cachex_sample) or [Github](https://github.com/lizhaochao/ecto_struct_cachex_sample).

## Problems Solving

- **Support getting struct by keyword from cache.**

```elixir
# define Cache by using ESC (ecto_struct_cachex)
defmodule StructCache do
  use ESC
end

# use StructCache to inject cache_struct/1, cache_put/1, cache_evict/1 decorators.
defmodule API do
  use StructCache

  # reformat resp by post_hook callback.
  def post_hook(resp), do: resp

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
## Contributing
Contributions to ecto_struct_cachex are very welcome!

Bug reports, documentation, spelling corrections... all of those (and probably more) are much appreciated contributions!
