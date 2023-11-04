defmodule CoreWeb.ContentComponents do
  @moduledoc """
  Provides content UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  # alias Phoenix.LiveView.JS
  # import CoreWeb.Gettext

  attr :rest, :global
  slot :inner_block, required: true, doc: "The title of the page"

  def page_title(assigns) do
    ~H"""
    <header>
      <div>
        <h1 id="page_title" {@rest}><%= render_slot(@inner_block) %></h1>
      </div>
    </header>
    """
  end

  attr :rest, :global
  attr :id, :string, required: true

  slot :tab, doc: "A list of tabs" do
    attr :patch, :string
  end

  slot :subtitle, doc: "A cute subtitle"
  slot :inner_block, required: true, doc: "The title of the section"

  def section_title(assigns) do
    ~H"""
    <h3 id={@id} {@rest}>
      <%= render_slot(@inner_block) %>
    </h3>
    <div :if={assigns[:tab]}>
      <nav>
        <.link :for={tab <- @tab} patch={tab.patch}>
          <%= render_slot(tab) %>
        </.link>
      </nav>
    </div>
    <p :if={@subtitle}><%= render_slot(@subtitle) %></p>
    """
  end

  attr :rest, :global
  slot :empty, doc: "An empty placeholder for the other cards"
  slot :cards, doc: "A list of cards"
  slot :inner_block, doc: "The main content of the card"

  def card_grid(assigns) do
    ~H"""
    <ul role="list" {@rest}>
      <%= @empty && render_slot(@empty) %>
      <%= render_slot(@inner_block) %>
      <%= render_slot(@cards) %>
    </ul>
    """
  end

  attr :rest, :global
  attr :image_url, :string, default: nil
  attr :image_alt, :string, default: nil
  slot :title, doc: "The title of the card"
  slot :image, doc: "An image at the top of the card"
  slot :inner_block, required: true, doc: "The main content of the card"
  slot :footer, doc: "The footer content of the card"

  def card(assigns) do
    ~H"""
    <li {@rest}>
      <section>
        <%= render_slot(@image) %>
        <img :if={@image_url} src={@image_url} alt={@image_alt} />
        <%= render_slot(@title) %>
        <%= render_slot(@inner_block) %>
      </section>
      <footer :if={@footer}>
        <%= render_slot(@footer) %>
      </footer>
    </li>
    """
  end

  @doc """
  Renders the site header
  """
  attr :current_account, Core.Users.Account, default: nil

  def site_header(assigns) do
    ~H"""
    <nav class="navbar navbar-expand-lg" style="background-color: #26324a;">
      <section class="container-fluid">
        <.link class="navbar-brand" href={~p"/"}><%= Application.get_env(:core, :application_name) %></.link>

        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <.site_header_link :if={@current_account} navigate={~p"/accounts/settings"}>Account</.site_header_link>
          <.site_header_link :if={@current_account} href={~p"/accounts/log_out"} method="delete">Log out</.site_header_link>
          <.site_header_link :if={!@current_account} navigate={~p"/accounts/register"}>Register</.site_header_link>
          <.site_header_link :if={!@current_account} navigate={~p"/accounts/log_in"}>Log in</.site_header_link>
        </ul>
      </section>
    </nav>
    """
  end

  attr :current?, :boolean, default: false

  attr :rest, :global,
    include: ~w(navigate href method),
    doc: "the arbitrary HTML attributes to add to the link"

  slot :inner_block, required: true

  def site_header_link(assigns) do
    ~H"""
    <li class="nav-item">
      <.link :if={@current?} aria-current="page" class="nav-link active" {@rest}>
        <%= render_slot(@inner_block) %>
      </.link>
      <.link :if={!@current?} class="nav-link" {@rest}>
        <%= render_slot(@inner_block) %>
      </.link>
    </li>
    """
  end

  @doc """
  Renders the site footer.
  """
  attr :current_account, Core.Users.Account, default: nil

  def site_footer(assigns) do
    ~H"""
    <footer class="container py-5">
      <div class="row">
        <div class="col-4 mb-3">
          <h2>
            <%= Application.get_env(:core, :application_name) %>
          </h2>
          <ul class="nav flex-column">
            <li class="nav-item mb-2"><.link class="nav-link p-0 text-body-secondary" navigate={~p"/"}>Home</.link></li>
            <li class="nav-item mb-2"><.link class="nav-link p-0 text-body-secondary" navigate={~p"/"}>Credits</.link></li>
            <li class="nav-item mb-2"><.link class="nav-link p-0 text-body-secondary" navigate={~p"/"}>FAQ</.link></li>
          </ul>
        </div>
        <div class="col-4 mb-3">
          <h5>User</h5>
          <ul class="nav flex-column">
            <li class="nav-item mb-2" :if={@current_account}>
              <strong><%= @current_account.username %></strong>
            </li>
            <li class="nav-item mb-2" :if={@current_account}>
              <.link class="nav-link p-0 text-body-secondary" navigate={~p"/accounts/settings"}>Account</.link>
            </li>
            <li class="nav-item mb-2" :if={@current_account}>
              <.link class="nav-link p-0 text-body-secondary" href={~p"/accounts/log_out"} method="delete">
                Log out
              </.link>
            </li>
            <li class="nav-item mb-2" :if={!@current_account}>
              <.link class="nav-link p-0 text-body-secondary" navigate={~p"/accounts/register"}>Register</.link>
            </li>
            <li class="nav-item mb-2" :if={!@current_account}>
              <.link class="nav-link p-0 text-body-secondary" navigate={~p"/accounts/log_in"}>Log in</.link>
            </li>
          </ul>
        </div>
        <div class="col-4 mb-3">
          <form>
            <h5>Subscribe to our newsletter</h5>
            <p>Monthly digest of what's new and exciting from us.</p>
            <div class="d-flex flex-column w-100 gap-2">
              <label for="newsletter1" class="visually-hidden">Email address</label>
              <input id="newsletter1" type="text" class="form-control" placeholder="Email address">
              <button class="btn btn-primary" type="button">Subscribe</button>
            </div>
          </form>
        </div>
      </div>

      <div class="d-flex flex-column justify-content-between py-4 my-4 border-top">
        <p>© 2023 Company, Inc. All rights reserved.</p>
        <ul class="list-unstyled d-flex">
          <li class="ms-3"><a class="link-body-emphasis" href="#"><svg class="bi" width="24" height="24"><use xlink:href="#twitter"></use></svg></a></li>
          <li class="ms-3"><a class="link-body-emphasis" href="#"><svg class="bi" width="24" height="24"><use xlink:href="#instagram"></use></svg></a></li>
          <li class="ms-3"><a class="link-body-emphasis" href="#"><svg class="bi" width="24" height="24"><use xlink:href="#facebook"></use></svg></a></li>
        </ul>
      </div>
    </footer>
    """
  end
end
