defmodule Pulsarius.Notifications.Webhooks do
  alias Pulsarius.Notifications.Webhooks.Slack
  alias Pulsarius.Notifications.Webhooks.MsTeams
  alias Pulsarius.Incidents.Incident
  alias Pulsarius.Monitoring.Monitor

  def deliver(%{webhook_url: webhook_url, body: body}) do
    HTTPoison.post(
      webhook_url,
      body,
      [{"Content-Type", "application/x-www-form-urlencoded"}]
    )
  end

  def notifications_for(type, params) do
    slack_notifications = apply(Slack, type, [params, get_webhook_urls(params, :slack)])
    ms_tems_notifications = apply(MsTeams, type, [params, get_webhook_urls(params, :ms_teams)])

    slack_notifications ++ ms_tems_notifications
  end

  def render_body(incident, template) do
    message =
      Phoenix.View.render_to_string(PulsariusWeb.WebhookView, template, incident: incident)

    Jason.encode!(%{text: message, type: "mrkdwn"})
  end

  defp get_webhook_urls(%Incident{} = incident, :slack) do
    extract_webhook_urls_from(incident.monitor, :slack_integrations)
  end

  defp get_webhook_urls(%Monitor{} = monitor, :slack) do
    extract_webhook_urls_from(monitor, :slack_integrations)
  end

  defp get_webhook_urls(%Incident{} = incident, :ms_teams) do
    extract_webhook_urls_from(incident.monitor, :ms_teams_integrations)
  end

  defp get_webhook_urls(%Monitor{} = monitor, :ms_teams) do
    extract_webhook_urls_from(monitor, :ms_teams_integrations)
  end

  defp extract_webhook_urls_from(resource, integration_type) do
   Pulsarius.Repo.preload(resource, integration_type)
    |> Map.get(integration_type)
    |> Enum.map(& &1.webhook_url)
  end
end

# body = URI.encode_query(%{
#   "code" => "4659483875559.4709218216352.cf1a4cd50b4c61b433c7307ffe553be3763f8a465655fddf7f531b373d1276af",
#   "client_id" => "4659483875559.4686702025457",
#   "client_secret" => "d4b34882b201055a88253f44980b7e1c"
# })

#  HTTPoison.post("https://slack.com/api/oauth.v2.access", body, [{"Content-Type", "application/x-www-form-urlencoded"}])  

# i = Pulsarius.Repo.get(Pulsarius.Incidents.Incident, "2304d27f-29ad-4720-8615-8b401b247827") |> Pulsarius.Repo.preload(:monitor) 
# Pulsarius.broadcast("incidents", {:incident_created, i}) 
