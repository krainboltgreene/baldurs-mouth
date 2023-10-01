import Config

config :core,
  signing_salt: "JKEx/AEF",
  domain: "www.project.com",
  base_url: "https://www.project.com/",
  production: true

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :core, CoreWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Core.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger,
  level: :info,
  backends: [:console, Sentry.LoggerBackend]

config :oban, log_level: :warning

config :sentry,
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_paths: [File.cwd!()],
  included_environments: [:prod]

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.