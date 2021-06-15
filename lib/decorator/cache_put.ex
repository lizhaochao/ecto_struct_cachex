defmodule ESC.Decorator.CachePut do
  @moduledoc false

  alias ESC.{Cache, Config, Hook}

  defmacro __using__(_opts) do
    quote do
      def cache_put(struct_name, block, %Decorator.Decorate.Context{} = ctx) do
        impl_m = __MODULE__

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
          |> Hook.post_hook(unquote(impl_m))
        end
      end
    end
  end
end
