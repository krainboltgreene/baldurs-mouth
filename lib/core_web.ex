defmodule CoreWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use CoreWeb, :controller
      use CoreWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: CoreWeb.Layouts]

      import Plug.Conn
      import CoreWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view(layout \\ :app) do
    quote do
      require Logger
      import Ecto.Query

      use Phoenix.LiveView,
        layout: {CoreWeb.Layouts, unquote(layout)}

      on_mount({CoreWeb.Live, :tenancy})

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import CoreWeb.CoreComponents
      import CoreWeb.FormComponents
      import CoreWeb.ContentComponents
      import CoreWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())

      def elixir_as_html(source) do
        inspect(source, pretty: true, limit: :infinity)
        |> (&"```\n#{&1}\n```").()
        |> Earmark.as_html!(smartypants: false, inner_html: true)
        |> Phoenix.HTML.raw()
      end

      def code_as_html(source) do
        source
        |> (&"```\n#{&1}\n```").()
        |> Earmark.as_html!(smartypants: false, inner_html: true)
        |> Phoenix.HTML.raw()
      end

      def error_at_ago(%{"at" => at}) do
        at
        |> DateTime.from_iso8601()
        |> case do
          {:ok, datetime, _} -> Timex.from_now(datetime)
          {:error, _} -> at
        end
      end
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: CoreWeb.Endpoint,
        router: CoreWeb.Router,
        statics: CoreWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__([which | options]) when is_atom(which) do
    apply(__MODULE__, which, options)
  end
end
