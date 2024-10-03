# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :pulsarius,
  ecto_repos: [Pulsarius.Repo]

# Configures the endpoint
config :pulsarius, PulsariusWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PulsariusWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Pulsarius.PubSub,
  live_view: [signing_salt: "CpPHcGEm"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.

# config :pulsarius, Pulsarius.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
# config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :pulsarius, :frequency_check_in_seconds_allowed_values, [60, 120, 180, 240, 300]

config :pulsarius, :api, url_monitor_api: Pulsarius.UrlMonitor.UrlMonitorClient

config :pulsarius, Pulsarius.Mailer, adapter: Swoosh.Adapters.Local

config :pulsarius, :email,
  alert_email_types: [:incident_created, :send_test_alert, :incident_auto_resolved],
  notification_types: [:user_invitation_created]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :pulsarius, :feature_plans,
  freelancer: %{
    monitoring_limit: 10,
    user_seats: 1,
    sms_notifications: false,
    monitoring_interval: 180,
    ssl_monitor: false,
    notification_types: 5,
    keyword_monitor: true
  },
  small_team: %{
    monitoring_limit: 50,
    user_seats: 1,
    monitoring_interval: 60,
    sms_notifications: true,
    keyword_monitor: true,
    ssl_monitor: true
  },
  bussines: %{
    monitoring_limit: 500,
    user_seats: 5,
    sms_notifications: true,
    monitoring_interval: 30,
    keyword_monitor: true,
    ssl_monitor: true
  }
