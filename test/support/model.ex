defmodule User do
  @moduledoc false
  defstruct([:id, :name, :role, :parent])
end

defmodule Role do
  @moduledoc false
  defstruct([:id, :name, :child])
end

defmodule Parent do
  @moduledoc false
  defstruct([:id, :name, :child])
end

defmodule Child do
  @moduledoc false
  defstruct([:id])
end
