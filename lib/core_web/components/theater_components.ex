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
    <div class="group block flex-shrink-0">
      <div class="flex items-center">
        <div>
          <img class="inline-block h-9 w-9 rounded-full" src="@character.avatar" alt="">
        </div>
        <div class="ml-3">
          <p class="text-sm font-medium text-gray-700 group-hover:text-gray-900"><%= Pretty.get(@character, :name) %></p>
          <p class="text-xs font-medium text-gray-500 group-hover:text-gray-700"><%= Pretty.get(@character.lineage, :name) %> <%= Pretty.get(@character.background, :name) %></p>
          <p class="text-xs font-medium text-gray-500 group-hover:text-gray-700"><%= Pretty.get(@character, :classes) %></p>
        </div>
      </div>
    </div>
    """
  end
end
