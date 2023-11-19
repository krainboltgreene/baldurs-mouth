defmodule CoreWeb.PageLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, %{transport_pid: nil} = socket),
    do:
      socket
      |> assign(:page_title, "Loading...")
      |> assign(:page_loading, true)
      |> (&{:ok, &1}).()

  def mount(_params, _session, %{assigns: %{live_action: :home}} = socket) do
    socket
    |> assign(:page_title, "Welcome to #{Application.get_env(:core, :application_name)}")
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
  end

  def mount(_params, _session, %{assigns: %{live_action: :credits}} = socket) do
    socket
    |> assign(:page_title, "Credits")
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  @spec render(%{:live_action => :home, optional(any()) => any()}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :home} = assigns) do
    ~H"""
    <div class="prose mx-auto my-4">
      <p>
        <strong>Baldur's Mouth</strong> is a miniature implementation of the <.link href="https://dnd.wizards.com/">Dungeons & Dragons 5th Edition roleplaying game</.link> and
        also a best attempt at replicating the <.link href="https://baldursgate3.game/">Baldur's Gate 3</.link> roleplaying game dialogue system. If you're old
        like me this will feel a lot like a text adventure or a choose-your-own-adventure novel. The name comes from the infamous
        newspaper of the titular Baldur's Gate in the fictional world of Faerûn.
      </p>
    </div>
    <div class="mx-auto max-w-lg">
      <.list>
        <:item :if={@current_account} icon={%{as: "play"}}>
          <.link navigate={~p"/saves/new"} class="underline">Start new game</.link>
        </:item>
        <:item :if={@current_account} icon={%{as: "save"}}>
          <.link navigate={~p"/saves"}>Load game</.link>
        </:item>
        <:item :if={@current_account} icon={%{as: "person"}}>
          <.link navigate={~p"/characters"}>Characters</.link>
        </:item>
        <:item :if={@current_account} icon={%{as: "map"}}>
          <.link navigate={~p"/campaigns"}>Campaigns</.link>
        </:item>
        <:item :if={!@current_account} icon={%{as: "unlock"}}>
          <.link navigate={~p"/accounts/log_in"} class="underline">Sign in</.link>
        </:item>
        <:item :if={!@current_account} icon={%{as: "user-plus"}}>
          <.link navigate={~p"/accounts/register"} class="underline">Sign up</.link>
        </:item>
        <:item icon={%{as: "list"}}>
          <.link navigate={~p"/credits"} class="underline">Credits</.link>
        </:item>
      </.list>
    </div>
    """
  end

  def render(%{live_action: :credits} = assigns) do
    ~H"""
    <div class="prose mx-auto my-4">
      <ul>
        <li>Kurtis Rainbolt-Greene (Programming, Writing)</li>
        <li>David Reeves (Writing)</li>
        <li>James (Feedback)</li>
        <li>Charlie (Feedback)</li>
        <li>Rani (RIP)</li>
      </ul>
    </div>
    """
  end
end
