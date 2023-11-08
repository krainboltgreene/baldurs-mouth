defmodule CoreWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  import CoreWeb.Gettext

  @spec flash(map()) :: Phoenix.LiveView.Rendered.t()
  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      role="alert"
      class={[
        "fixed top-2 right-2 mr-2 w-80 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} as="information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} as="exclamation-circle-mini" class="h-4 w-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-sm leading-5"><%= msg %></p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon as="x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title="Success!" flash={@flash} />
      <.flash kind={:error} title="Error!" flash={@flash} />
      <.flash id="client-error" kind={:error} title="We can't find the internet"  hidden>
        Attempting to reconnect <.icon as="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash id="server-error" kind={:error} title="Something went wrong!" hidden>
        Hang in there while we get back on track <.icon as="arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @spec button(map()) :: Phoenix.LiveView.Rendered.t()
  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :state, :string, default: "usable"
  attr :rejection_icon, :string, default: "warning"
  attr :busy_icon, :string, default: "clock"
  attr :failure_icon, :string, default: "bug"
  attr :successful_icon, :string, default: "check"
  attr :usable_icon, :string, required: true
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button :if={@state == "rejection"} disabled class={["phx-submit-loading:opacity-75 inline-flex items-center gap-x-1.5 rounded-md bg-red-500 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600", @class]} {@rest}>
      <.icon as={@rejection_icon} /> <%= render_slot(@inner_block) %> Rejected
    </button>
    <button :if={@state == "failure"} disabled class={["phx-submit-loading:opacity-75 inline-flex items-center gap-x-1.5 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", @class]} {@rest}>
      <.icon as={@failure_icon} /> <%= render_slot(@inner_block) %> Failed
    </button>
    <button :if={@state == "successful"} disabled class={["phx-submit-loading:opacity-75 inline-flex items-center gap-x-1.5 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", @class]} {@rest}>
      <.icon as={@successful_icon} /> <%= render_slot(@inner_block) %> Successful
    </button>
    <button :if={@state == "busy"} disabled class={["phx-submit-loading:opacity-75 inline-flex items-center gap-x-1.5 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", @class]} {@rest}>
      <.icon as={@busy_icon} /> Busy...
    </button>
    <button :if={@state == "usable" || @state == nil} class={["phx-submit-loading:opacity-75 inline-flex items-center gap-x-1.5 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", @class]} {@rest}>
      <.icon as={@usable_icon} /> <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4">
      <table class="w-[40rem] mt-11">
        <thead class="text-sm text-left leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal"><%= col[:label] %></th>
            <th :if={@action != []} class="relative p-0 pb-4">
              <span class="sr-only"><%= gettext("Actions") %></span>
            </th>
          </tr>
        </thead>
        <tbody id={@id} phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"} class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700">
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td :for={{col, i} <- Enum.with_index(@col)} phx-click={@row_click && @row_click.(row)} class={["relative p-0", @row_click && "hover:cursor-pointer"]}>
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, @row_item.(row)) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50" />
                <span :for={action <- @action} class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
                  <%= render_slot(action, @row_item.(row)) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6">
          <dt class="w-1/4 flex-none text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @spec icon(map()) :: Phoenix.LiveView.Rendered.t()
  attr :type, :string, default: "solid"
  attr :as, :string, required: true
  attr :modifiers, :string, default: ""
  attr :rest, :global, include: ~w(disabled form name value class)

  def icon(assigns) do
    ~H"""
    <i class={"fa-#{@type} fa-#{@as} #{@modifiers}"} {@rest}></i>
    """
  end

  @spec loading_text_indicator(map()) :: Phoenix.LiveView.Rendered.t()
  attr :size, :integer, default: 12

  def loading_text_indicator(assigns) do
    ~H"""
    <.icon :for={number <- 1..@size} as="square-full" modifiers="fa-fade text-highlight-500" style={"--fa-animation-duration: 3s; --fa-fade-opacity: 0.2; --fa-animation-delay: #{number / 2.0}s"} />
    """
  end

  @spec timestamp_in_words_ago(map()) :: Phoenix.LiveView.Rendered.t()
  attr :at, NaiveDateTime, required: true
  attr :rest, :global

  def timestamp_in_words_ago(assigns) do
    ~H"""
    <time time={@at} title={@at}><%= Timex.from_now(@at) %></time>
    """
  end

  @spec tag(map()) :: Phoenix.LiveView.Rendered.t()
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def tag(assigns) do
    ~H"""
    <span class="inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10" {@rest}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  @spec page_title(map()) :: Phoenix.LiveView.Rendered.t()
  attr :subtitle, :string, doc: "A smaller piece of accompanying text"
  attr :rest, :global
  slot :inner_block, required: true, doc: "The title of the page"

  def page_title(assigns) do
    ~H"""
    <header class="bg-dark-500">
      <div class="mx-auto max-w-7xl py-2 px-3">
        <h1 id="page_title" class="text-2xl font-bold leading-tight tracking-tight text-highlight-500" {@rest}><%= render_slot(@inner_block) %></h1>
        <p :if={assigns[:subtitle]} id="page_subtitle" class="text-sm font-semibold leading-tight tracking-tight text-highlight-600" {@rest}><%= @subtitle %></p>
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
end
