defmodule Pulsarius.Notifications.Webhooks do
  alias Pulsarius.Notifications.Webhooks.Slack

  def deliver(%{webhook_url: webhook_url, body: body}) do
    HTTPoison.post(
      webhook_url,
      body,
      [{"Content-Type", "application/x-www-form-urlencoded"}]
    )
  end

  def notifications_for(type, incident) do
    slack_integration_enabled? = incident.monitor.configuration.slack_notification

    cond do
      slack_integration_enabled? ->
        webhook_url = incident.monitor.configuration.slack_notification_webhook_url
        [apply(Slack, type, [incident, webhook_url])]

      # ms_teams_integration_enabled? -> 
      # [apply(MsTeams, type, args)]
      true ->
        []
    end
  end

  def render_body(incident, template) do
    message =
      Phoenix.View.render_to_string(PulsariusWeb.WebhookView, template, incident: incident)

    Jason.encode!(%{text: message, type: "mrkdwn"})
  end
end

# body = URI.encode_query(%{
#   "code" => "4659483875559.4709218216352.cf1a4cd50b4c61b433c7307ffe553be3763f8a465655fddf7f531b373d1276af",
#   "client_id" => "4659483875559.4686702025457",
#   "client_secret" => "d4b34882b201055a88253f44980b7e1c"
# })

#  HTTPoison.post("https://slack.com/api/oauth.v2.access", body, [{"Content-Type", "application/x-www-form-urlencoded"}])  
