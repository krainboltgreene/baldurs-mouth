defmodule CoreWeb.AccountConfirmationInstructionsLive do
  use CoreWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Resend Confirmation Instructions")
    |> assign(:form, to_form(%{}, as: "account"))
    |> (&{:ok, &1}).()
  end

  def handle_event(
        "send_instructions",
        %{"account" => %{"email_address" => email_address}},
        socket
      ) do
    if account = Core.Users.get_account_by_email_address(email_address) do
      Core.Users.deliver_account_confirmation_instructions(
        account,
        &url(~p"/accounts/confirm/#{&1}")
      )
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."
     )
     |> redirect(to: ~p"/")}
  end

  def render(assigns) do
    ~H"""
    <p>
      No confirmation instructions received?
      We'll send a new confirmation link to your inbox
    </p>

    <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={@form[:email_address]} type="email" label="Email" required />
      <:actions>
        <.button phx-disable-with="Sending..." type="submit" usable_icon="envelope" kind="primary">
          Resend confirmation instructions
        </.button>
      </:actions>
    </.simple_form>

    <p>
      <.link navigate={~p"/accounts/register"}>Register</.link> | <.link navigate={~p"/accounts/log_in"}>Log in</.link>
    </p>
    """
  end
end
