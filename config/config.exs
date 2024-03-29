# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :contact_analytics, ContactAnalytics.Mailer, adapter: Swoosh.Adapters.Local

config :contact_analytics, ContactAnalytics.Repo,
  url: "mongodb://10.0.2.2:27017/contact_analytics",
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000

config :mongodb_driver,
  migration: [
    topology: :mongo,
    collection: "migrations",
    path: "migrations",
    otp_app: :contact_analytics
  ]


config :contact_analytics_web,
  generators: [context_app: :contact_analytics]

# Configures the endpoint
config :contact_analytics_web, ContactAnalyticsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ContactAnalyticsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ContactAnalytics.PubSub,
  live_view: [signing_salt: "KeEiVErx"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
