defmodule ESC.Hook do
  @moduledoc false

  def post_hook(resp, impl_m) do
    with(
      {f, a} <- __ENV__.function,
      true <- function_exported?(impl_m, f, a - 1)
    ) do
      apply(impl_m, f, [resp])
    else
      false -> resp
    end
  end
end
