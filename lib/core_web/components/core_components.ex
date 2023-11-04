defmodule CoreWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  # alias Phoenix.LiveView.JS
  # import CoreWeb.Gettext

  @spec tag(map()) :: Phoenix.LiveView.Rendered.t()
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def tag(assigns) do
    ~H"""
    <span class="inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10" {@rest}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  @spec flash(map()) :: Phoenix.LiveView.Rendered.t()
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
        "rounded-md p-4",
        @kind == :info && "bg-blue-50",
        @kind == :error && "bg-yellow-50"
      ]}
      role="alert"
      {@rest}
    >
      <div class="flex">
        <div :if={@icon} class="flex-shrink-0">
          <%= @icon %> Icon
        </div>
        <div class="ml-3">
          <h3 :if={@title} class={["text-sm font-medium", @kind == :info && "bg-blue-50", @kind == :error && "text-yellow-800"]}><%= @title %></h3>
          <div class={["mt-2 text-sm", @kind == :info && "bg-blue-50", @kind == :error && "text-yellow-700"]}>
            <%= msg %>
          </div>
          <div :if={@context} class={["mt-2 text-sm", @kind == :info && "bg-blue-50", @kind == :error && "text-yellow-700"]}>
            <%= @context %>
          </div>
        </div>
        <div class="ml-auto pl-3">
          <div class="-mx-1.5 -my-1.5">
            <%!-- Switch to button component --%>
            <.button
              type="button"
              class={[
                "inline-flex rounded-md p-1.5 focus:outline-none focus:ring-2 focus:ring-green-600 focus:ring-offset-2",
                @kind == :success && "bg-green-50 text-green-500 hover:bg-green-100 focus:ring-offset-green-50"
              ]}
              usable_icon="xmark"
            >
              <span class="sr-only">Dismiss</span>
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @spec button(map()) :: Phoenix.LiveView.Rendered.t()
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
  attr :class, :list, default: []
  attr :rest, :global, include: ~w(disabled form name value)
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button :if={@state == "rejection"} disabled class={["inline-flex items-center gap-x-1.5 rounded-md bg-red-500 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600", @class]} {@rest}>
      <.icon as={@rejection_icon} /> <%= render_slot(@inner_block) %> Rejected
    </button>
    <button :if={@state == "failure"} disabled class={["inline-flex items-center gap-x-1.5 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", @class]} {@rest}>
      <.icon as={@failure_icon} /> <%= render_slot(@inner_block) %> Failed
    </button>
    <button :if={@state == "successful"} disabled class={["inline-flex items-center gap-x-1.5 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", @class]} {@rest}>
      <.icon as={@successful_icon} /> <%= render_slot(@inner_block) %> Successful
    </button>
    <button :if={@state == "busy"} disabled class={["inline-flex items-center gap-x-1.5 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", @class]} {@rest}>
      <.icon as={@busy_icon} /> Busy...
    </button>
    <button :if={@state == "usable" || @state == nil} class={["inline-flex items-center gap-x-1.5 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", @class]} {@rest}>
      <.icon as={@usable_icon} /> <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @spec icon(map()) :: Phoenix.LiveView.Rendered.t()
  attr :type, :string, default: "solid"
  attr :as, :string, required: true
  attr :modifiers, :string, default: ""
  attr :rest, :global, include: ~w(disabled form name value class)

  def icon(assigns) do
    ~H"""
    <i class={"fa-#{@type} fa-#{@as} #{@modifiers}"} {@rest}></i>
    """
  end

  @spec loading_text_indicator(map()) :: Phoenix.LiveView.Rendered.t()
  attr :size, :integer, default: 12

  def loading_text_indicator(assigns) do
    ~H"""
    <.icon :for={number <- 1..@size} as="square-full" modifiers="fa-fade text-highlight-500" style={"--fa-animation-duration: 3s; --fa-fade-opacity: 0.2; --fa-animation-delay: #{number / 2.0}s"} />
    """
  end

  @spec timestamp_in_words_ago(map()) :: Phoenix.LiveView.Rendered.t()
  attr :at, NaiveDateTime, required: true
  attr :rest, :global

  def timestamp_in_words_ago(assigns) do
    ~H"""
    <time time={@at} title={@at}><%= Timex.from_now(@at) %></time>
    """
  end
end
