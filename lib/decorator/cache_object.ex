defmodule ESC.Decorator.CacheObject do
  @moduledoc false

  alias ESC.Cache

  defmacro __using__(_opts) do
    quote do
      def cache_object(struct_name, block, %Decorator.Decorate.Context{args: args_expr} = ctx) do
        quote do
          with(
            exec_block <- fn -> unquote(block) end,
            struct_name <- unquote(struct_name),
            [conds_or_id] <- unquote(args_expr)
          ) do
            Cache.get(struct_name, conds_or_id, exec_block)
          end
        end
      end
    end
  end
end
