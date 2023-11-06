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
    <div class="inline-block rounded-md p-1.5 text-xs ring-1 ring-inset bg-gray-50 border border-gray-300 ring-gray-500/10 shadow-sm focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:border-gray-400">
      <img class="inline-block h-3 w-3 rounded-full" src={~p"/images/class-fighter.svg"} alt="" />
      <%= Pretty.get(@character, :name) %>
    </div>
    """
  end
end
