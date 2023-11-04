defmodule CoreWeb.TheaterComponents do
  @moduledoc """
  Provides thearer UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  attr :character, Core.Gameplay.Character, required: true
  @spec speaker(%{character: Core.Gameplay.Character.t()}) :: Phoenix.LiveView.Rendered.t()
  def speaker(assigns) do
    ~H"""
    <div>
      <div>
        <div>
          <img src="@character.avatar" alt="">
        </div>
        <div>
          <p><%= Pretty.get(@character, :name) %></p>
          <p><%= Pretty.get(@character.lineage, :name) %> <%= Pretty.get(@character.background, :name) %></p>
          <p><%= Pretty.get(@character, :classes) %></p>
        </div>
      </div>
    </div>
    """
  end
end
