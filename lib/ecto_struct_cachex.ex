defmodule ESC do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      use Decorator.Define, cache_object: 1, cache_put: 1
      use ESC.Decorator.CacheObject, unquote(opts)
      use ESC.Decorator.CachePut, unquote(opts)
    end
  end
end
