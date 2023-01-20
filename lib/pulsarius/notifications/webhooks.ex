defmodule Pulsarius.Notifications.Webhooks do
  alias Pulsarius.Notifications.Webhooks.SlackClient

  def incident_created(_incident, webhook_url) do
    message =
      Phoenix.View.render_to_string(PulsariusWeb.WebhookView, "incident_created.html", %{})

    body = Jason.encode!(%{text: message, type: "mrkdwn"})

    %{webhook_url: webhook_url, body: body}
  end

  def deliver(%{webhook_url: webhook_url, body: body}) do
    SlackClient.send(webhook_url, body)
  end
end
