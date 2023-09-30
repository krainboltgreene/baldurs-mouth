defmodule Core.Users.AccountNotifier do
  @moduledoc false
  import Swoosh.Email

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({
        Application.get_env(:core, :application_name),
        Application.get_env(:core, :support_email_address)
      })
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Core.Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(account, url) do
    deliver(
      account.email_address,
      "Finish setting up your #{Application.get_env(:core, :application_name)} Account",
      """

      ==============================

      Hi #{account.email_address},

      You can confirm your account by visiting the URL below:

      #{url}

      If you didn't create an account with us, please ignore this.

      ==============================
      """
    )
  end

  @doc """
  Deliver instructions to reset a account password.
  """
  def deliver_reset_password_instructions(account, url) do
    deliver(account.email_address, "Reset password instructions", """

    ==============================

    Hi #{account.email_address},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a account email.
  """
  def deliver_update_email_address_instructions(account, url) do
    deliver(account.email_address, "Update email instructions", """

    ==============================

    Hi #{account.email_address},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
