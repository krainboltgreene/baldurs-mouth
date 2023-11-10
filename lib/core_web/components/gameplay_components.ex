defmodule CoreWeb.GameplayComponents do
  @moduledoc """
  Provides gameplay UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  @spec sheet(%{character: Core.Gameplay.Character.t()}) :: Phoenix.LiveView.Rendered.t()
  attr :character, Core.Gameplay.Character, required: true

  def sheet(assigns) do
    ~H"""
    <CoreWeb.CoreComponents.list>
      <:item title="Lineage"><%= Pretty.get(@character.lineage, :name) %></:item>
      <:item title="Background"><%= Pretty.get(@character.background, :name) %></:item>
      <:item title="Level"><%= Pretty.get(@character, :level) %> (<%= Pretty.get(@character, :xp) %>xp)</:item>
      <:item title="Class(es)"><%= Pretty.get(@character, :classes) %></:item>
      <:item title="Proficiency Bonus"><%= Pretty.get(@character, :proficiency_bonus) %></:item>
      <:item title="Hitpoints"><%= Pretty.get(@character, :hitpoints) %>/<%= Pretty.get(@character, :hitpoints) %></:item>
      <:item title="Ability Score">
        <CoreWeb.CoreComponents.list>
          <:item title="Strength"><%= Pretty.get(@character, :strength) %></:item>
          <:item title="Dexterity"><%= Pretty.get(@character, :dexterity) %></:item>
          <:item title="Constitution"><%= Pretty.get(@character, :constitution) %></:item>
          <:item title="Intelligence"><%= Pretty.get(@character, :intelligence) %></:item>
          <:item title="Wisdom"><%= Pretty.get(@character, :wisdom) %></:item>
          <:item title="Charisma"><%= Pretty.get(@character, :charisma) %></:item>
        </CoreWeb.CoreComponents.list>
      </:item>
    </CoreWeb.CoreComponents.list>
    """
  end
end
