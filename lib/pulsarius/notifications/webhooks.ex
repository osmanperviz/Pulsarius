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
    apply(Slack, type, [params, get_webhook_url(params, :slack)])
    apply(MsTeams, type, [params, get_webhook_url(params, :ms_teams)])
    # cond do
    #   # slack_integration_enabled?(params) ->
    #   true ->
    #     apply(Slack, type, [params, get_webhook_url(params, :slack)])

    #   # ms_teams_integration_enabled? -> 
    #   # [apply(MsTeams, type, args)]
    #   true ->
    #     []
    # end
  end

  def render_body(incident, template) do
    message =
      Phoenix.View.render_to_string(PulsariusWeb.WebhookView, template, incident: incident)

    Jason.encode!(%{text: message, type: "mrkdwn"})
  end

  # TODO: REFACTURE THIS!
  defp slack_integration_enabled?(%Incident{} = incident) do
    incident.monitor.configuration.slack_notification
  end

  defp slack_integration_enabled?(%Monitor{} = monitor) do
    monitor.configuration.slack_notification
  end

  defp get_webhook_url(%Incident{} = incident, :slack) do
    Pulsarius.Repo.preload(incident.monitor, :slack_integrations)
    |> Map.get(:slack_integrations)
    |> Enum.map(& &1.webhook_url)
  end

  defp get_webhook_url(%Monitor{} = monitor, :slack) do
    Pulsarius.Repo.preload(monitor, :slack_integrations)
    |> Map.get(:slack_integrations)
    |> Enum.map(& &1.webhook_url)
  end

  defp get_webhook_url(%Monitor{} = monitor, :ms_teams) do
    Pulsarius.Repo.preload(monitor, :ms_teams_integrations)
    |> Map.get(:ms_teams_integrations)
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
