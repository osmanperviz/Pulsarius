defmodule Pulsarius.Notifications.Webhooks.Slack do
  @moduledoc """
    Implementing Notification protocol, responsible for sending and composing different types of Slack notifications.
  """

  alias Pulsarius.Notifications.Webhooks

  @type t :: %__MODULE__{type: atom, webhook_url: String.t(), body: String.t()}
  @type incident :: Incident.t()
  @type webhook_url :: String.t()
  @type webhook_urls :: [String.t()]
  @type monitor :: Monitor.t()

  defstruct [:type, :webhook_url, :body]

  @spec incident_created(incident, webhook_urls) :: [Slack.t()]
  def incident_created(incident, webhook_urls) do
    body = Webhooks.render_body(incident, "incident_created.html")

    webhook_urls
    |> Enum.map(&build_template(:incidentincident_created_auto_resolved, &1, body))
  end

  @spec incident_auto_resolved(incident, webhook_urls) :: [Slack.t()]
  def incident_auto_resolved(incident, webhook_urls) do
    body = Webhooks.render_body(incident, "incident_auto_resolved.html")

    webhook_urls
    |> Enum.map(&build_template(:incident_auto_resolved, &1, body))
  end

  @spec monitor_paused(monitor, webhook_urls) :: [Slack.t()]
  def monitor_paused(monitor, webhook_urls) do
    body = Webhooks.render_body(monitor, "monitor_paused.html")

    webhook_urls
    |> Enum.map(&build_template(:monitor_paused, &1, body))
  end

  @spec monitor_unpaused(monitor, webhook_urls) :: [Slack.t()]
  def monitor_unpaused(monitor, webhook_urls) do
    body = Webhooks.render_body(monitor, "monitor_unpaused.html")

    webhook_urls
    |> Enum.map(&build_template(:monitor_unpaused, &1, body))
  end

  defp build_template(type, webhook_url, body) do
    %__MODULE__{type: type, webhook_url: webhook_url, body: body}
  end

  defimpl Pulsarius.Notifications.Notification, for: Pulsarius.Notifications.Webhooks.Slack do
    alias Pulsarius.Notifications.Webhooks

    @spec send(%{args: list, body: String.t()}) :: :ok
    def send(%{webhook_url: _webhook_url, body: _body} = slack_notification) do
      Webhooks.deliver(slack_notification)
    end
  end
end
