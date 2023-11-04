defmodule CoreWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  # alias Phoenix.LiveView.JS
  # import CoreWeb.Gettext

  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def tag(assigns) do
    ~H"""
    <span {@rest}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  @doc """
  Renders flash notices.
  ## Examples
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :icon, :string, default: nil
  attr :context, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :close, :boolean, default: true, doc: "whether the flash can be closed"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(%{flash: %{"error" => error_messages}} = assigns) when is_list(error_messages) do
    ~H"""
    <.flash :for={error_message <- @flash["error"]} kind={:error}>
      <%= error_message %>
    </.flash>
    """
  end

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      class={[
        "",
        @kind == :info && "",
        @kind == :error && ""
      ]}
      role="alert"
      {@rest}
    >
      <div>
        <div :if={@icon}>
          <%= @icon %> Icon
        </div>
        <div>
          <h3 :if={@title} class={["", @kind == :info && "", @kind == :error && ""]}><%= @title %></h3>
          <div class={["", @kind == :info && "", @kind == :error && ""]}>
            <%= msg %>
          </div>
          <div :if={@context} class={["", @kind == :info && "", @kind == :error && ""]}>
            <%= @context %>
          </div>
        </div>
        <div>
          <div>
            <.button
              type="button"
              class={[
                "",
                @kind == :success && ""
              ]}
              usable_icon="xmark"
              phx-click="clear_flash"
            >
              Dismiss
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go">Send!</.button>
  """
  attr :state, :string, default: "usable"
  attr :rejection_icon, :string, default: "warning"
  attr :busy_icon, :string, default: "clock"
  attr :failure_icon, :string, default: "bug"
  attr :successful_icon, :string, default: "check"
  attr :usable_icon, :string, required: true
  attr :kind, :string, default: nil
  attr :class, :list, default: []
  attr :rest, :global, include: ~w(disabled form name value)
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button :if={@state == "rejection"} disabled class={["btn", "btn-warning", @class]} {@rest}>
      <.icon as={@rejection_icon} /> <%= render_slot(@inner_block) %> Rejected
    </button>
    <button :if={@state == "failure"} disabled class={["btn", "btn-danger", @class]} {@rest}>
      <.icon as={@failure_icon} /> <%= render_slot(@inner_block) %> Failed
    </button>
    <button :if={@state == "successful"} disabled class={["btn", "btn-success", @class]} {@rest}>
      <.icon as={@successful_icon} /> <%= render_slot(@inner_block) %> Successful
    </button>
    <button :if={@state == "busy"} disabled class={["btn", "btn-#{@kind}", @class]} {@rest}>
      <.icon as={@busy_icon} /> Busy...
    </button>
    <button :if={@state == "usable" || @state == nil} class={["btn", "btn-#{@kind}", @class]} {@rest}>
      <.icon as={@usable_icon} /> <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :type, :string, default: "solid"
  attr :as, :string, required: true
  attr :modifiers, :string, default: ""
  attr :rest, :global, include: ~w(disabled form name value class)

  def icon(assigns) do
    ~H"""
    <i class={"fa-#{@type} fa-#{@as} #{@modifiers}"} {@rest}></i>
    """
  end

  attr :size, :integer, default: 12

  def loading_text_indicator(assigns) do
    ~H"""
    <.icon :for={number <- 1..@size} as="square-full" modifiers="fa-fade" style={"--fa-animation-duration: 3s; --fa-fade-opacity: 0.2; --fa-animation-delay: #{number / 2.0}s"} />
    """
  end

  attr :at, NaiveDateTime, required: true
  attr :rest, :global

  def timestamp_in_words_ago(assigns) do
    ~H"""
    <time time={@at} title={@at}><%= Timex.from_now(@at) %></time>
    """
  end
end
