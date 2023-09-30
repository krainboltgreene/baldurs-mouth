defmodule CoreWeb.Router do
  use CoreWeb, :router

  import CoreWeb.AccountAuthenticationHelpers
  import Phoenix.LiveDashboard.Router
  import CoreWeb.Plugs.Tenancy, only: [require_tenancy: 2]

  import CoreWeb.Plugs.Administration,
    only: [require_administrative_privilages: 2]

  import CoreWeb.Plugs.Namespace,
    only: [set_namespace: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CoreWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
    plug Ueberauth
    plug CoreWeb.Plugs.Tenancy
  end

  pipeline :api do
    plug :fetch_session
    plug :put_secure_browser_headers
    plug :fetch_current_account
    plug :accepts, ["json", "image/png"]
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
      live "/about_us", CoreWeb.PageLive, :about_us
      live "/pricing", CoreWeb.PageLive, :pricing
      live "/faq", CoreWeb.PageLive, :faq
      live "/accounts/confirm/:token", CoreWeb.AccountConfirmationLive, :edit
      live "/accounts/confirm", CoreWeb.AccountConfirmationInstructionsLive, :new
    end
  end

  scope "/admin", as: :admin do
    pipe_through [
      :browser,
      :require_authenticated_account,
      :set_namespace,
      :require_administrative_privilages
    ]

    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    live_dashboard "/phoenix", metrics: CoreWeb.Telemetry

    live_session :admin,
      on_mount: [
        {CoreWeb.AccountAuthenticationHelpers, :ensure_authenticated},
        {CoreWeb.Plugs.Namespace, :set_namespace},
        {CoreWeb.Plugs.Administration, :require_administrative_privilages}
      ] do
      live "/", CoreWeb.AdminPageLive, :dashboard
      live "/jobs/:id", CoreWeb.JobLive, :show
      live "/jobs", CoreWeb.JobLive, :list
      live "/webhooks/:id", CoreWeb.WebhookLive, :show
      live "/webhooks", CoreWeb.WebhookLive, :list
      live "/organizations/:id", CoreWeb.OrganizationLive, :show
      live "/organizations", CoreWeb.OrganizationLive, :list
      live "/accounts/:id", CoreWeb.AccountLive, :show
      live "/accounts", CoreWeb.AccountLive, :list
    end
  end

  scope "/" do
    pipe_through [:browser, :require_authenticated_account]

    live_session :require_authenticated_account,
      on_mount: [
        {CoreWeb.AccountAuthenticationHelpers, :ensure_authenticated}
      ] do
      live "/accounts/settings", CoreWeb.AccountSettingsLive, :edit
      live "/accounts/settings/confirm_email/:token", CoreWeb.AccountSettingsLive, :confirm_email
    end
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:core, :dev_routes) do
    scope "/dev" do
      pipe_through [:browser, :require_authenticated_account]

      forward "/mailbox", Plug.Swoosh.MailboxPreview

      live_session :require_authenticated_account_for_dev,
        on_mount: [
          {CoreWeb.AccountAuthenticationHelpers, :ensure_authenticated}
        ] do
        live "/playground", CoreWeb.PlaygroundLive, :list
      end
    end
  end
end
