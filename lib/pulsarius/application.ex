defmodule Pulsarius.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Pulsarius.Repo,
      # Start the Telemetry supervisor
      PulsariusWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Pulsarius.PubSub},
      # Start the Endpoint (http/https)
      PulsariusWeb.Endpoint,
      {Pulsarius.EndpointDynamicSupervisor,
       name: Pulsarius.EndpointDynamicSupervisor, strategy: :one_for_one},
      {Registry, [keys: :unique, name: :url_monitor]},
      # On application boot it starts all interrupted monitor processes again.
      {Task, fn -> Pulsarius.EndpointDynamicSupervisor.auto_start_monitoring() end},
      # Start a worker by calling: Pulsarius.Worker.start_link(arg)
      # {Pulsarius.Worker, arg}

      # process responsible for handeling notifications
      Pulsarius.Notifications.NotificationServer,

      # process stripe webhook notifications
      Pulsarius.Billing.ProcessWebhook
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pulsarius.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PulsariusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
