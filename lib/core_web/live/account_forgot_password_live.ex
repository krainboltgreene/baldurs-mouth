defmodule CoreWeb.AccountForgotPasswordLive do
  use CoreWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Forgot your password?")
    |> assign(:form, to_form(%{}, as: "account"))
    |> (&{:ok, &1}).()
  end

  def handle_event("send_email", %{"account" => %{"email_address" => email_address}}, socket) do
    if account = Core.Users.get_account_by_email_address(email_address) do
      Core.Users.deliver_account_reset_password_instructions(
        account,
        &url(~p"/accounts/reset_password/#{&1}")
      )
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       "If your email is in our system, you will receive instructions to reset your password shortly."
     )
     |> redirect(to: ~p"/")}
  end

  def render(assigns) do
    ~H"""
    <p>
      We'll send a password reset link to your inbox
    </p>

    <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
      <.input field={@form[:email_address]} type="email" placeholder="Email" required />
      <:actions>
        <.button phx-disable-with="Sending..." type="submit" usable_icon="envelope" kind="primary">
          Send password reset instructions
        </.button>
      </:actions>
    </.simple_form>
    <p>
      <.link href={~p"/accounts/register"}>Register</.link> | <.link href={~p"/accounts/log_in"}>Log in</.link>
    </p>
    """
  end
end
