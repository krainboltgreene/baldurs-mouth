defmodule CoreWeb.AccountRegistrationLive do
  use CoreWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Register Account")
    |> assign_form(Core.Users.change_account_registration(%Core.Users.Account{}))
    |> assign(:check_errors, false)
    |> assign(:trigger_submit, false)
    |> (&{:ok, &1, temporary_assigns: [form: nil], layout: {CoreWeb.Layouts, :empty}}).()
  end

  def handle_event("save", %{"account" => account_params}, socket) do
    case Core.Users.register_account(account_params) do
      {:ok, account} ->
        {:ok, _} =
          Core.Users.deliver_account_confirmation_instructions(
            account,
            &url(~p"/accounts/confirm/#{&1}")
          )

        changeset = Core.Users.change_account_registration(account)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"account" => account_params}, socket) do
    changeset = Core.Users.change_account_registration(%Core.Users.Account{}, account_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "account")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <p class="text-center my-4">
        Already registered? <.link navigate={~p"/accounts/log_in"} class="text-dark-500 font-medium hover:underline">Sign in to your account now.</.link>
      </p>

      <.simple_form for={@form} id="registration_form" phx-submit="save" phx-change="validate" phx-trigger-action={@trigger_submit} action={~p"/accounts/log_in?_action=registered"} method="post">
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email_address]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button type="submit" phx-disable-with="Creating account..." usable_icon="check">
            Create an account
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
