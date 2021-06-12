defmodule ESC.Decorator.CachePut do
  @moduledoc false

  alias ESC.Cache

  defmacro __using__(_opts) do
    quote do
      def cache_put(struct_name, block, %Decorator.Decorate.Context{} = ctx) do
        quote do
          with(
            exec_block <- fn -> unquote(block) end,
            struct_name <- unquote(struct_name)
          ) do
            Cache.put(struct_name, exec_block)
          end
        end
      end
    end
  end
end
