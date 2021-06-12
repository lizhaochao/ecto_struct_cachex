defmodule ESC do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      use Decorator.Define, cache_object: 1
      use ESC.Decorator.CacheObject, unquote(opts)
    end
  end
end
