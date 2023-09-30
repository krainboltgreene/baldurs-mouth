defmodule Core.Cldr do
  @moduledoc """
  This module allows us to transform different values into strings.
  """
  use Cldr,
    default_locale: "en",
    json_library: Jason,
    providers: [Cldr.Number]
end
