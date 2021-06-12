defmodule User do
  defstruct [:id, :name, :role]
end

defmodule Role do
  defstruct [:id, :name]
end

defmodule Parent do
  defstruct [:id, :name, :child]
end

defmodule Child do
  defstruct [:id]
end
