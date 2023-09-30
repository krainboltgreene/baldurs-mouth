import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :argon2_elixir, t_cost: 1, m_cost: 8

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :core, Core.Repo,
  username: "postgres",
  password: if(System.get_env("CI"), do: "postgres"),
  hostname: "localhost",
  database: "core_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :core, CoreWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "7GnUU++jStQkHY0f1Kj72K3ttoieHe4llePjJMlkQcTzoKomuSnIWU6OjNcJKK8x",
  server: false

# In test we don't send emails.
config :core, Core.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

config :core, Oban, testing: :inline

config :oban, log_level: :debug

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
