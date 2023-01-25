defmodule PulsariusWeb.IntegrationController do
  use PulsariusWeb, :controller

  alias Pulsarius.Integrations.Slack.SlackClient
  alias Pulsarius.Monitoring
  alias Pulsarius.Configurations

  def index(conn, %{"id" => id, "code" => code} = _params) do
    {:ok, data} = SlackClient.fetch_data(code)
    monitor = Monitoring.get_monitor!(id)

    params = %{
      "slack_notification" => true,
      "slack_notification_webhook_url" => data["incoming_webhook"]["url"]
    }

    {:ok, configuration} =
      monitor.configuration
      |> Configurations.update_configuration(params)

    conn
    |> put_flash(:success, "You have successfully added slack integration.")
    |> redirect(to: Routes.monitor_show_path(conn, :show, monitor))
  end
end
