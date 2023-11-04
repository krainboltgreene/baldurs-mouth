defmodule CoreWeb.AccountSettingsLive do
  use CoreWeb, :live_view

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Core.Users.update_account_email_address(socket.assigns.current_account, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/accounts/settings")}
  end

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account

    socket =
      socket
      |> assign(:page_title, "Account Settings")
      |> assign(:current_account, account)
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, account.email_address)
      |> assign(:email_form, to_form(Core.Users.change_account_email_address(account)))
      |> assign(:password_form, to_form(Core.Users.change_account_password(account)))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "account" => account_params} = params

    email_form =
      socket.assigns.current_account
      |> Core.Users.change_account_email_address(account_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "account" => account_params} = params
    account = socket.assigns.current_account

    case Core.Users.apply_account_email_address(account, password, account_params) do
      {:ok, applied_account} ->
        Core.Users.deliver_account_update_email_address_instructions(
          applied_account,
          account.email_address,
          &url(~p"/accounts/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "account" => account_params} = params

    password_form =
      socket.assigns.current_account
      |> Core.Users.change_account_password(account_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "account" => account_params} = params
    account = socket.assigns.current_account

    case Core.Users.update_account_password(account, password, account_params) do
      {:ok, account} ->
        password_form =
          account
          |> Core.Users.change_account_password(account_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <p>
      Manage your account email address and password settings
    </p>

    <div>
      <div>
        <.simple_form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email">
          <.input field={@email_form[:email_address]} type="email" label="Email" required />
          <.input field={@email_form[:current_password]} name="current_password" id="current_password_for_email" type="password" label="Current password" value={@email_form_current_password} required />
          <:actions>
            <.button phx-disable-with="Changing..." type="submit" usable_icon="save" kind="primary">Change Email</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form for={@password_form} id="password_form" action={~p"/accounts/log_in?_action=password_updated"} method="post" phx-change="validate_password" phx-submit="update_password" phx-trigger-action={@trigger_submit}>
          <.input field={@password_form[:email_address]} type="hidden" id="hidden_account_email" value={@current_email} />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input field={@password_form[:password_confirmation]} type="password" label="Confirm new password" />
          <.input field={@password_form[:current_password]} name="current_password" type="password" label="Current password" id="current_password_for_password" value={@current_password} required />
          <:actions>
            <.button phx-disable-with="Changing..." type="submit" usable_icon="save" kind="primary">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end
end
