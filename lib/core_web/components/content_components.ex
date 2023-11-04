defmodule CoreWeb.ContentComponents do
  @moduledoc """
  Provides content UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  # alias Phoenix.LiveView.JS
  # import CoreWeb.Gettext

  @spec page_title(map()) :: Phoenix.LiveView.Rendered.t()
  attr :rest, :global
  slot :inner_block, required: true, doc: "The title of the page"

  def page_title(assigns) do
    ~H"""
    <header class="bg-dark-500">
      <div class="mx-auto max-w-7xl py-2 px-3">
        <h1 id="page_title" class="text-3xl font-bold leading-tight tracking-tight text-light-500" {@rest}><%= render_slot(@inner_block) %></h1>
      </div>
    </header>
    """
  end

  @spec section_title(map()) :: Phoenix.LiveView.Rendered.t()
  attr :rest, :global
  attr :id, :string, required: true

  slot :tab, doc: "A list of tabs" do
    attr :patch, :string
  end

  slot :subtitle, doc: "A cute subtitle"
  slot :inner_block, required: true, doc: "The title of the section"

  def section_title(assigns) do
    ~H"""
    <div class="border-b border-gray-200 mt-8 mb-4">
      <div class="ml-2 mt-2 flex flex-wrap items-baseline">
        <h3 class="ml-2 mt-2 text-base font-semibold leading-6 text-gray-900" id={@id} {@rest}>
          <%= render_slot(@inner_block) %>
        </h3>
        <div :if={assigns[:tab]} class="mt-4">
          <nav class="-mb-px flex space-x-8">
            <!-- Current: "border-indigo-500 text-indigo-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700" -->
            <.link :for={tab <- @tab} patch={tab.patch} class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 whitespace-nowrap border-b-2 px-1 pb-2 text-sm font-medium">
              <%= render_slot(tab) %>
            </.link>
          </nav>
        </div>
        <p :if={@subtitle} class="ml-2 mt-1 truncate text-sm text-gray-500"><%= render_slot(@subtitle) %></p>
      </div>
    </div>
    """
  end

  @spec card_grid(map()) :: Phoenix.LiveView.Rendered.t()
  attr :rest, :global
  slot :empty, doc: "An empty placeholder for the other cards"
  slot :cards, doc: "A list of cards"
  slot :inner_block, doc: "The main content of the card"

  def card_grid(assigns) do
    ~H"""
    <ul role="list" class="grid grid-cols-1 gap-6 grid-cols-3" {@rest}>
      <%= @empty && render_slot(@empty) %>
      <%= render_slot(@inner_block) %>
      <%= render_slot(@cards) %>
    </ul>
    """
  end

  @spec card(map()) :: Phoenix.LiveView.Rendered.t()
  attr :rest, :global
  attr :image_url, :string, default: nil
  attr :image_alt, :string, default: nil
  slot :title, doc: "The title of the card"
  slot :image, doc: "An image at the top of the card"
  slot :inner_block, required: true, doc: "The main content of the card"
  slot :footer, doc: "The footer content of the card"

  def card(assigns) do
    ~H"""
    <li class="max-w-sm rounded overflow-shadow-lg border-dark-500 bg-white flex flex-col items-center border-2 border-contrast-500" {@rest}>
      <div class="px-6 py-4 basis-3/4 flex flex-col justify-center">
        <%= render_slot(@image) %>
        <img :if={@image_url} class="mx-auto h-32 w-32 flex-shrink-0" src={@image_url} alt={@image_alt} />
        <%= render_slot(@title) %>
        <%= render_slot(@inner_block) %>
      </div>
      <div :if={@footer} class="px-6 pt-4 pb-2 basis-1/4 flex flex-col justify-center">
        <%= render_slot(@footer) %>
      </div>
    </li>
    """
  end

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
            <h2 class="mb-4 text-sm font-semibold text-highlight-500 uppercase">
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
