defmodule CoreWeb.Plugs.Namespace do
  @moduledoc """
  This plug intercepts requests for the namespaced routes and tells the application it's that namespace.
  """
  import Plug.Conn

  @spec set_namespace(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def set_namespace(%Plug.Conn{path_info: [name | _]} = conn, _opts) do
    conn
    |> assign(:namespace, name)
    |> put_session(:namespace, name)
  end

  def set_namespace(conn, _opts) do
    conn
    |> assign(:namespace, nil)
    |> put_session(:namespace, nil)
  end

  def on_mount(
        :set_namespace,
        _params,
        _session,
        %{assigns: %{namespace: namespace}} = socket
      ) do
    socket
    |> Phoenix.Component.assign(:namespace, namespace)
    |> (&{:cont, &1}).()
  end

  def on_mount(
        :set_namespace,
        _params,
        %{"namespace" => namespace},
        socket
      ) do
    socket
    |> Phoenix.Component.assign(:namespace, namespace)
    |> (&{:cont, &1}).()
  end

  def on_mount(
        :set_namespace,
        _params,
        _session,
        socket
      ) do
    socket
    |> Phoenix.Component.assign(:namespace, nil)
    |> (&{:cont, &1}).()
  end
end
