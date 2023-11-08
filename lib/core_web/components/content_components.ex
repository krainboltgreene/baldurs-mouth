defmodule CoreWeb.ContentComponents do
  @moduledoc """
  Provides content UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  # import CoreWeb.Gettext

  @spec site_header(map()) :: Phoenix.LiveView.Rendered.t()
  @doc """
  Renders the site header
  """
  attr :current_account, Core.Users.Account, default: nil

  def site_header(assigns) do
    ~H"""
    <nav class="">
      <div class="mx-auto px-4 border-b-2 border-dark-500 bg-white">
        <div class="flex h-16 justify-between">
          <div class="flex">
            <div class="flex flex-shrink-0 items-center">
              <h1 class="text-3xl font-bold leading-tight tracking-tight text-gray-900"><%= Application.get_env(:core, :application_name) %></h1>
            </div>
          </div>

          <div class="flex">
            <.site_header_link :if={@current_account} navigate={~p"/accounts/settings"}>Account</.site_header_link>
            <.site_header_link :if={@current_account} href={~p"/accounts/log_out"} method="delete">Log out</.site_header_link>
            <.site_header_link :if={!@current_account} navigate={~p"/accounts/register"}>Register</.site_header_link>
            <.site_header_link :if={!@current_account} navigate={~p"/accounts/log_in"}>Log in</.site_header_link>
          </div>
        </div>
      </div>
    </nav>
    """
  end

  @spec site_header_link(map()) :: Phoenix.LiveView.Rendered.t()
  attr :current?, :boolean, default: false

  attr :rest, :global,
    include: ~w(navigate href method),
    doc: "the arbitrary HTML attributes to add to the link"

  slot :inner_block, required: true

  def site_header_link(assigns) do
    ~H"""
    <.link :if={@current?} class="border-indigo-500 text-contrast-500 inline-flex items-center px-1 pt-1 text-sm font-medium decoration-solid" aria-current="page" {@rest}>
      <%= render_slot(@inner_block) %>
    </.link>
    <.link :if={!@current?} class="text-contrast-500 hover:border-gray-300 hover:text-highlight-500 inline-flex items-center px-1 pt-1 text-sm font-medium decoration-solid" {@rest}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  @spec site_footer(map()) :: Phoenix.LiveView.Rendered.t()
  @doc """
  Renders the site footer.
  """
  attr :current_account, Core.Users.Account, default: nil

  def site_footer(assigns) do
    ~H"""
    <footer class="bg-dark-500 text-contrast-500">
      <div class="mx-auto w-full max-w-screen-xl">
        <div class="grid grid-cols-2 gap-8 px-3 py-2">
          <div>
            <h2 class="mb-4 text-lg font-semibold text-highlight-300 uppercase">
              <%= Application.get_env(:core, :application_name) %>
            </h2>
            <ul>
              <li class="mb-1">
                <.link navigate={~p"/"} class="text-light-500 font-medium hover:underline">Home</.link>
              </li>
            </ul>
          </div>
          <div>
            <h2 class="mb-4 text-sm font-semibold text-highlight-500 uppercase">
              Authentication
            </h2>
            <ul>
              <li :if={@current_account} class="mb-1">
                <strong class="text-light-500 font-medium"><%= @current_account.username %></strong>
              </li>
              <li :if={@current_account} class="mb-1">
                <.link navigate={~p"/accounts/settings"} class="text-light-500 font-medium hover:underline">Account</.link>
              </li>
              <li :if={@current_account} class="mb-1">
                <.link href={~p"/accounts/log_out"} method="delete" class="text-light-500 font-medium hover:underline">
                  Log out
                </.link>
              </li>
              <li :if={!@current_account} class="mb-1">
                <.link navigate={~p"/accounts/register"} class="text-light-500 font-medium hover:underline">Register</.link>
              </li>
              <li :if={!@current_account} class="mb-1">
                <.link navigate={~p"/accounts/log_in"} class="text-light-500 font-medium hover:underline">Log in</.link>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </footer>
    """
  end
end
