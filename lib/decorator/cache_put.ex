defmodule ESC.Decorator.CachePut do
  @moduledoc false

  alias ESC.Decorator.CachePut, as: Self
  alias ESC.Cache

  defmacro __using__(_opts) do
    quote do
      def cache_put(struct_name, block, %Decorator.Decorate.Context{} = ctx) do
        Self.cache_put(struct_name, block)
      end
    end
  end

  def cache_put(struct_name_expr, block) do
    quote do
      with(
        exec_block <- fn -> unquote(block) end,
        struct_name <- unquote(struct_name_expr)
      ) do
        val = Cache.put(struct_name, exec_block)
        val
      end
    end
  end
end
