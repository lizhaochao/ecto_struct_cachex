defmodule User do
  @moduledoc false
  defstruct([:id, :name, :role])
end

defmodule Role do
  @moduledoc false
  defstruct([:id, :name])
end

defmodule Parent do
  @moduledoc false
  defstruct([:id, :name, :child])
end

defmodule Child do
  @moduledoc false
  defstruct([:id])
end
