defmodule ESC.Decorator.CacheObject do
  @moduledoc false

  alias ESC.Decorator.CacheObject, as: Self
  alias ESC.Cache

  defmacro __using__(_opts) do
    quote do
      def cache_object(struct_name, block, %Decorator.Decorate.Context{} = ctx) do
        %{args: args_expr} = ctx
        Self.cache_object(struct_name, args_expr, block)
      end
    end
  end

  def cache_object(struct_name_expr, args_expr, block) do
    quote do
      with(
        exec_block <- fn -> unquote(block) end,
        struct_name <- unquote(struct_name_expr),
        [conds_or_id] <- unquote(args_expr)
      ) do
        val = Cache.get(struct_name, conds_or_id, exec_block)
        val
      end
    end
  end
end
