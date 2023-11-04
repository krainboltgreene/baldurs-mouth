# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :core,
  ecto_repos: [Core.Repo],
  generators: [binary_id: true],
  application_name: "Baldur's Mouth",
  support_email_address: "support@baldurs-mouth.com",
  theme_color: "#ffffff",
  description: "",
  short_description: "",
  google_site_verification: "",
  google_tag_manager_id: ""

config :core,
       Core.Repo,
       migration_primary_key: [name: :id, type: :binary_id],
       migration_foreign_key: [column: :id, type: :binary_id]

# Configures the endpoint
config :core, CoreWeb.Endpoint,
  url: [host: Application.get_env(:core, :domain)],
  render_errors: [
    formats: [html: CoreWeb.ErrorHTML, json: CoreWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Core.PubSub,
  live_view: [signing_salt: "JKEx/AEF"]

config :ueberauth, Ueberauth,
  providers: [
    twitch: {Ueberauth.Strategy.Twitch, [default_scope: "user:read:email"]}
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :core, Core.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/application.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure sass (the version is required)
config :dart_sass,
  version: "1.61.0",
  default: [
    args: ~w(css/application.scss ../priv/static/assets/application.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
import IO

# Configures Elixir's Logger
config :logger, :console,
  format: "$metadata[$level] #{IO.ANSI.bright()}$message#{IO.ANSI.normal()}\n",
  metadata: [:request_id],
  color: :enabled

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
