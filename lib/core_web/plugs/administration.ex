defmodule CoreWeb.Plugs.Administration do
  @moduledoc """
  This plug intercepts requests for the admin resoures and tells the application it's in admin mode.
  """
  use CoreWeb, :verified_routes
  import Plug.Conn
  import Phoenix.Controller

  def require_administrative_privilages(
        %Plug.Conn{assigns: %{current_account: current_account}} = conn,
        _opts
      ) do
    current_account
    |> Core.Users.has_permission?("global", "administrator")
    |> case do
      true ->
        conn

      false ->
        conn
        |> put_flash(:error, "That page does not exist.")
        |> maybe_store_return_to()
        |> redirect(to: ~p"/")
        |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :account_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  def on_mount(
        :require_administrative_privilages,
        _params,
        _session,
        %{assigns: %{current_account: current_account}} = socket
      ) do
    current_account
    |> Core.Users.has_permission?("global", "administrator")
    |> case do
      true ->
        socket
        |> (&{:cont, &1}).()

      false ->
        socket
        |> Phoenix.LiveView.put_flash(:error, "That page does not exist.")
        |> Phoenix.LiveView.redirect(to: ~p"/")
        |> (&{:halt, &1}).()
    end
  end

  def on_mount(:require_administrative_privilages, _params, _session, socket) do
    socket
    |> Phoenix.LiveView.put_flash(:error, "That page does not exist.")
    |> Phoenix.LiveView.redirect(to: ~p"/")
    |> (&{:halt, &1}).()
  end
end
