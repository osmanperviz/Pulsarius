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
      [{"Content-Type", "application/json"}]
    )
  end

  defp render_body(incident, template) do
    message =
      Phoenix.View.render_to_string(PulsariusWeb.WebhookView, template, incident: incident)

    Jason.encode!(%{text: message, type: "mrkdwn"})
  end
end
