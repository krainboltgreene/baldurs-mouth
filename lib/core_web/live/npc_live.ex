defmodule CoreWeb.NPCLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(
        _params,
        _session,
        %{assigns: %{current_account: %Core.Users.Account{username: username}}}
      )
      when username != "krainboltgreene",
      do: raise(CoreWeb.Exceptions.NotFoundException)

  def mount(_params, _session, %{transport_pid: nil} = socket),
    do:
      socket
      |> assign(:page_title, "Loading...")
      |> assign(:page_loading, true)
      |> (&{:ok, &1}).()

  def mount(%{"id" => npc_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    npc =
      Core.Theater.get_npc(npc_id)
      |> Core.Repo.preload([])

    socket
    |> assign(:npc, npc)
    |> assign(:page_title, npc.name)
    |> assign(:page_subtitle, "NPC")
    |> (&{:ok, &1}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  # @impl true
  # def handle_event(
  #       "...",
  #       %{},
  #       %{assigns: %{...}} = socket
  #     ) do
  #   socket
  #   |> (&{:noreply, &1}).()
  # end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any()) => any()}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{page_loading: true} = assigns) do
    ~H"""
    Loading...
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <.list>
      <:item title="Name">
        <%= Pretty.get(@npc, :name) %>
      </:item>
    </.list>
    """
  end
end
