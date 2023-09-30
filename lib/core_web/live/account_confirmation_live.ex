defmodule CoreWeb.AccountConfirmationLive do
  use CoreWeb, :live_view

  def mount(%{"token" => token}, _session, socket) do
    socket
    |> assign(:page_title, "Confirm Account")
    |> assign(form: to_form(%{"token" => token}, as: "account"))
    |> (&{:ok, &1, temporary_assigns: [form: nil]}).()
  end

  # Do not log in the account after confirmation to avoid a
  # leaked token giving the account access to the account.
  def handle_event("confirm_account", %{"account" => %{"token" => token}}, socket) do
    case Core.Users.confirm_account(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current account and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the account themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_account: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "Account confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <.simple_form for={@form} id="confirmation_form" phx-submit="confirm_account">
      <.input field={@form[:token]} type="hidden" />
      <:actions>
        <.button phx-disable-with="Confirming..." type="submit" usable_icon="envelope">
          Confirm my account
        </.button>
      </:actions>
    </.simple_form>

    <p>
      <.link navigate={~p"/accounts/register"}>Register</.link> | <.link navigate={~p"/accounts/log_in"}>Log in</.link>
    </p>
    """
  end
end
