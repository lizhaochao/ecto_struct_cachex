defmodule ESC.Decorator.CacheStruct do
  @moduledoc false

  alias ESC.{Cache, Config, Hook}

  defmacro __using__(_opts) do
    quote do
      def cache_struct(struct_name, block, %Decorator.Decorate.Context{args: args_expr} = ctx) do
        impl_m = __MODULE__

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
          |> Hook.post_hook(unquote(impl_m))
        end
      end
    end
  end
end
