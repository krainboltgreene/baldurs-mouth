defmodule CoreWeb.AdminPageLive do
  @moduledoc false
  use CoreWeb, :live_view

  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :refresh, 5000)

    socket
    |> assign(:page_title, "Admin")
    |> (&{:ok, &1}).()
  end

  @impl true
  def handle_params(params, _url, socket) do
    if connected?(socket) do
      socket
      |> assign(:insight, params["insight"])
      |> (&{:noreply, &1}).()
    else
      socket
      |> assign(:insight, params["insight"])
      |> (&{:noreply, &1}).()
    end
  end

  @impl true
  def handle_info(:refresh, %{assigns: %{live_action: :dashboard}} = socket) do
    Process.send_after(self(), :refresh, 5000)
    {:noreply, push_patch(socket, to: "/admin", replace: true)}
  end

  @impl true
  def handle_info(:refresh, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(%{live_action: :dashboard} = assigns) do
    ~H"""
    The administrative dashboard.
    <.section_title id="insights">
      Insights
    </.section_title>
    """
  end
end
