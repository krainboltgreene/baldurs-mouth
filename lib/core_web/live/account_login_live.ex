defmodule CoreWeb.AccountLoginLive do
  use CoreWeb, :live_view

  def mount(_params, _session, socket) do
    email_address = live_flash(socket.assigns.flash, :email_address)

    socket
    |> assign(:page_title, "Sign In")
    |> assign(:form, to_form(%{"email_address" => email_address}, as: "account"))
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
  end

  def render(assigns) do
    ~H"""
    <div>
      <p>
        Don't have an account? <.link navigate={~p"/accounts/register"}>Sign up for a free account now</.link>.
      </p>

      <.simple_form for={@form} id="login_form" action={~p"/accounts/log_in"} phx-update="ignore">
        <.input field={@form[:email_address]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/accounts/reset_password"}>
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button type="submit" phx-disable-with="Sigining in..." usable_icon="check" kind="primary">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
