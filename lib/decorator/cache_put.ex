defmodule ESC.Decorator.CachePut do
  @moduledoc false

  alias ESC.{Cache, Config}

  defmacro __using__(_opts) do
    quote do
      def cache_put(struct_name, block, %Decorator.Decorate.Context{} = ctx) do
        quote do
          with(
            false = _disable <- Config.get_disable(),
            exec_block <- fn -> unquote(block) end,
            struct_name <- unquote(struct_name)
          ) do
            Cache.put(struct_name, exec_block)
          else
            true -> unquote(block)
          end
        end
      end
    end
  end
end
