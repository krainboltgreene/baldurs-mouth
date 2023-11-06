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
    <div class="mx-12">
      <ul role="list" class="divide-y divide-gray-100">
        <li :if={@current_account} class="flex gap-x-4 py-4">
          <div class="min-w-0">
            <p class="font-medium leading-6 text-gray-900">
              <.icon as="play" /> <.link navigate={~p"/saves"} class="underline">Start new game</.link>
            </p>
          </div>
        </li>
        <li :if={@current_account} class="flex gap-x-4 py-4">
          <div class="min-w-0">
            <p class="font-medium leading-6 text-gray-900">
              <.icon as="save" /> <.link navigate={~p"/saves"}>Load game</.link>
            </p>
          </div>
        </li>
        <li :if={!@current_account} class="flex gap-x-4 py-4">
          <div class="min-w-0">
            <p class="font-medium leading-6 text-gray-900">
              <.link navigate={~p"/accounts/log_in"} class="underline">Sign in</.link>
            </p>
          </div>
        </li>
        <li :if={!@current_account} class="flex gap-x-4 py-4">
          <div class="min-w-0">
            <p class="font-medium leading-6 text-gray-900">
              <.link navigate={~p"/accounts/register"} class="underline">Sign up</.link>
            </p>
          </div>
        </li>
        <li class="flex gap-x-4 py-5">
          <div class="min-w-0">
            <p class="font-medium leading-6 text-gray-900">Credits</p>
          </div>
        </li>
      </ul>
    </div>
    """
  end
end
