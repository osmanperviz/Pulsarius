defmodule Pulsarius.Notifications.Webhooks do
  alias Pulsarius.Notifications.Webhooks.SlackClient

  @spec incident_created(Incident.t(), String.t()) :: %{
          webhook_url: String.t(),
          body: String.t()
        }
  def incident_created(incident, webhook_url) do
    body =
      incident
      |> render_body("incident_created.html")

    %{webhook_url: webhook_url, body: body}
  end

  @spec incident_auto_resolved(Incident.t(), String.t()) :: %{
          webhook_url: String.t(),
          body: String.t()
        }
  def incident_auto_resolved(incident, webhook_url) do
    body =
      incident
      |> render_body("incident_auto_resolved.html")

    %{webhook_url: webhook_url, body: body}
  end

  def deliver(%{webhook_url: webhook_url, body: body}) do
    HTTPoison.post(
      webhook_url,
      body,
      [{"Content-Type", "application/x-www-form-urlencoded"}]
    )
  end

  defp render_body(incident, template) do
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
