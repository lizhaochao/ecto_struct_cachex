defmodule User, do: defstruct([:id, :name, :role])
defmodule Role, do: defstruct([:id, :name])
defmodule Parent, do: defstruct([:id, :name, :child])
defmodule Child, do: defstruct([:id])
