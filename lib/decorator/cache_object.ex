defmodule ESC.Decorator.CacheObject do
  @moduledoc false

  alias ESC.{Cache, Config}

  defmacro __using__(_opts) do
    quote do
      def cache_object(struct_name, block, %Decorator.Decorate.Context{args: args_expr} = ctx) do
        quote do
          with(
            false = _disable <- Config.get_disable(),
            exec_block <- fn -> unquote(block) end,
            struct_name <- unquote(struct_name),
            [conds_or_id | _] <- unquote(args_expr)
          ) do
            Cache.get(struct_name, conds_or_id, exec_block)
          else
            true -> unquote(block)
          end
        end
      end
    end
  end
end
