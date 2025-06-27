import Config

# No database configuration needed for this app

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :stoic_bard, StoicBardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "4BlachJiQQE7+qCLSLGBnczTz48UNk3Sd7BkPG6sbBaEhkq8wkGD/L47AVhbP6R3",
  server: false

# In test we don't send emails
config :stoic_bard, StoicBard.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
