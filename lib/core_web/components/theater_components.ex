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
    <div class="group inline-block rounded-md mt-0.5 px-1.5 py-0.5 text-xs ring-1 ring-inset bg-gray-50 border border-gray-300 ring-gray-500/10 shadow-sm focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:border-gray-400">
      <img class="inline-block h-9 w-9 rounded-full" src={~p"/images/class-fighter.svg"} alt="" />
      <%= Pretty.get(@character, :name) %>
    </div>
    """
  end
end
