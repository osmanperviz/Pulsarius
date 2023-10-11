import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/pulsarius start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :pulsarius, PulsariusWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :pulsarius, Pulsarius.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :pulsarius, PulsariusWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  config :pulsarius, :slack_integration,
    client_id: "4659483875559.4686702025457",
    client_secret: "d4b34882b201055a88253f44980b7e1c"

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :pulsarius, Pulsarius.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.

  stripe_api_key =
    System.get_env("STRIPE_API_KEY") ||
      raise """
      environment variable STRIPE_API_KEY is missing.
      You can obtain it from the stripe dashboard: https://dashboard.stripe.com/test/apikeys
      """

  stripe_webhook_key =
    System.get_env("STRIPE_WEBHOOK_SIGNING_SECRET") ||
      raise """
      environment variable STRIPE_WEBHOOK_SIGNING_SECRET is missing.
      You can obtain it from the stripe dashboard: https://dashboard.stripe.com/account/webhooks
      """

  config :stripity_stripe,
    api_key: stripe_api_key,
    signing_secret: stripe_webhook_key

  config :ex_aws,
    access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
    secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
    s3: [
      scheme: "https://",
      host: "pulsarius-dev.s3.amazonaws.com",
      region: "EU (Frankfurt) eu-central-1"
    ]

  config :pulsarius, Cafu.Mailer,
    adapter: Swoosh.Adapters.Mailjet,
    api_key:
      System.get_env("MAILJET_API_KEY") ||
        raise("YOU SHALL NOT PASS! Set the MAILJET_API_KEY first."),
    secret:
      System.get_env("MAILJET_SECRET") ||
        raise("YOU SHALL NOT PASS! Set the MAILJET_SECRET first.")

  config :rollbax,
    access_token: System.fetch_env!("ROLLBAR_ACCESS_TOKEN"),
    environment: System.fetch_env!("ROLLBAR_ENVIRONMENT")

  config :ueberauth, Ueberauth.Strategy.Passwordless,
    token_secret: "MK5izBztrRZoUmfc8P/XwoBXmOKzEE8o",
    mailer: MyApp.MyMailer
end
