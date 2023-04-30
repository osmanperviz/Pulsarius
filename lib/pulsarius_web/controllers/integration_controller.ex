defmodule PulsariusWeb.IntegrationController do
  use PulsariusWeb, :controller

  alias Pulsarius.Integrations.Slack.SlackClient
  alias Pulsarius.Integrations
  alias Pulsarius.Accounts

  def index(conn, %{"id" => id, "code" => code} = _params) do
    {:ok, %{"incoming_webhook" => incoming_webhook}} = SlackClient.fetch_data(code)
    account = Accounts.get_account!(id)

    IO.inspect(incoming_webhook, label: "incoming_webhook =====>")

    params = %{
      "channel_name" => Map.get(incoming_webhook, "channel"),
      "webhook_url" => Map.get(incoming_webhook, "url"),
      "channel_id" => Map.get(incoming_webhook, "channel_id"),
      "type" => "slack"
    }

    {:ok, integration} = Integrations.create_integration(account, params)

    conn
    |> put_flash(:success, "You have successfully added slack integration.")
    |> redirect(to: Routes.integrations_index_path(conn, :index))
  end
end
