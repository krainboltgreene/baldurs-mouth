defmodule Core.Data do
  defmodule Forced do
    @enforce_keys [:name, :type]
    defstruct [:name, :type]
  end

  defmodule AnyOf do
    @enforce_keys [:names, :type, :count]
    defstruct [:names, :type, :count, unique: true]
  end

  @type forced_t :: %__MODULE__.Forced{name: atom(), type: atom()}
  @type any_of_t :: %__MODULE__.AnyOf{
          names: list(atom()),
          type: atom(),
          count: integer(),
          unique: boolean()
        }
end
