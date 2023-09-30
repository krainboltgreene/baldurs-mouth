defmodule Core.Content do
  @moduledoc """
  Behavior for interacting with user generated content
  """
  require Logger
  import Ecto.Query

  use Scaffolding, [Core.Content.Webhook, :webhooks, :webhook]
end
