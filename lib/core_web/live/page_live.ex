defmodule CoreWeb.PageLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, %{assigns: %{live_action: :home}} = socket) do
    socket
    |> assign(:page_title, "Welcome to #{Application.get_env(:core, :application_name)}")
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
  end

  def mount(_params, _session, %{assigns: %{live_action: :pricing}} = socket) do
    socket
    |> assign(:page_title, "Pricing")
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
  end

  def mount(_params, _session, %{assigns: %{live_action: :about_us}} = socket) do
    socket
    |> assign(:page_title, "About Us")
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
  end

  def mount(_params, _session, %{assigns: %{live_action: :faq}} = socket) do
    socket
    |> assign(:page_title, "Frequently Asked Questions")
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :home} = assigns) do
    ~H"""
    """
  end

  @impl true
  def render(%{live_action: :pricing} = assigns) do
    ~H"""
    """
  end

  @impl true
  def render(%{live_action: :about_us} = assigns) do
    ~H"""
    """
  end

  @impl true
  def render(%{live_action: :faq} = assigns) do
    ~H"""
    """
  end

  defp call_to_action(assigns) do
    ~H"""
    <p class="my-4">
      <.link navigate={~p"/accounts/register"} class="text-dark-500 font-medium hover:underline">Create an account for free</.link> or <.link navigate={~p"/accounts/log_in"} class="text-dark-500 font-medium hover:underline">Sign into your existing account</.link>
    </p>
    """
  end
end
