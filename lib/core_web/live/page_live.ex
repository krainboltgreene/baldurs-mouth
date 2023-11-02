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
    <div class="mx-auto max-w-lg px-4 py-12">
      <ul role="list" class="divide-y divide-gray-100">
        <li class="flex gap-x-4 py-5">
          <div class="min-w-0">
            <p class="text-sm font-semibold leading-6 text-gray-900"><.link navigate={~p"/play/start"} class="font-medium underline">Start</.link></p>
          </div>
        </li>
        <li class="flex gap-x-4 py-5">
          <div class="min-w-0">
            <p class="text-sm font-semibold leading-6 text-gray-900">Credits</p>
          </div>
        </li>
      </ul>
    </div>
    """
  end
end
