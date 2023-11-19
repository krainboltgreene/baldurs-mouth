defmodule CoreWeb.Router do
  use CoreWeb, :router

  import CoreWeb.AccountAuthenticationHelpers
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CoreWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
    plug Ueberauth
  end

  pipeline :api do
    plug :fetch_session
    plug :put_secure_browser_headers
    plug :fetch_current_account
  end

  scope "/auth" do
    pipe_through :browser

    get "/:provider", CoreWeb.AccountSessionController, :request
    get "/:provider/callback", CoreWeb.AccountSessionController, :callback
  end

  scope "/" do
    pipe_through [:browser, :redirect_if_account_is_authenticated]

    live_session :redirect_if_account_is_authenticated,
      on_mount: [{CoreWeb.AccountAuthenticationHelpers, :redirect_if_account_is_authenticated}] do
      live "/accounts/register", CoreWeb.AccountRegistrationLive, :new
      live "/accounts/log_in", CoreWeb.AccountLoginLive, :new
      live "/accounts/reset_password", CoreWeb.AccountForgotPasswordLive, :new
      live "/accounts/reset_password/:token", CoreWeb.AccountResetPasswordLive, :edit
    end

    post "/accounts/log_in", CoreWeb.AccountSessionController, :create
  end

  scope "/" do
    pipe_through [:browser]

    delete "/accounts/log_out", CoreWeb.AccountSessionController, :delete
  end

  scope "/" do
    pipe_through [:browser]

    live_session :current_account,
      on_mount: [
        {CoreWeb.AccountAuthenticationHelpers, :mount_current_account}
      ] do
      live "/", CoreWeb.PageLive, :home
      live "/credits", CoreWeb.PageLive, :credits
      live "/accounts/confirm/:token", CoreWeb.AccountConfirmationLive, :edit
      live "/accounts/confirm", CoreWeb.AccountConfirmationInstructionsLive, :new
    end
  end

  scope "/" do
    pipe_through [:browser, :require_authenticated_account]
    live_dashboard "/phoenix", metrics: CoreWeb.Telemetry

    live_session :require_authenticated_account,
      on_mount: [
        {CoreWeb.AccountAuthenticationHelpers, :ensure_authenticated}
      ] do
      live "/campaigns", CoreWeb.CampaignLive, :list
      live "/campaigns/:id", CoreWeb.CampaignLive, :show
      live "/scenes/:id", CoreWeb.SceneLive, :show
      live "/dialogues/:id", CoreWeb.DialogueLive, :show
      live "/lines/:id", CoreWeb.LineLive, :show
      live "/npcs/:id", CoreWeb.NPCLive, :show
      live "/characters", CoreWeb.CharacterLive, :list
      live "/characters/new", CoreWeb.CharacterLive, :new
      live "/characters/:id", CoreWeb.CharacterLive, :show
      live "/saves", CoreWeb.SaveLive, :list
      live "/saves/new", CoreWeb.SaveLive, :new
      live "/saves/:id", CoreWeb.SaveLive, :show
      live "/accounts/settings", CoreWeb.AccountSettingsLive, :edit
      live "/accounts/settings/confirm_email/:token", CoreWeb.AccountSettingsLive, :confirm_email
    end
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:core, :dev_routes) do
    scope "/dev" do
      pipe_through [:browser, :require_authenticated_account]

      forward "/mailbox", Plug.Swoosh.MailboxPreview

      live "/playground", CoreWeb.PlaygroundLive, :list
    end
  end
end
