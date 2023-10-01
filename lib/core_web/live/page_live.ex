defmodule CoreWeb.PageLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, %{assigns: %{live_action: :home}} = socket) do
    socket
    |> assign(:page_title, "Welcome to #{Application.get_env(:core, :application_name)}")
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
end
