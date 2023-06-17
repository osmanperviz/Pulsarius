defmodule Pulsarius.Notifications.Webhooks.Slack do
  @moduledoc """
    Implementing Notification protocol, responsible for sending and composing different types of Slack notifications.
  """

  alias Pulsarius.Notifications.Webhooks
  alias Pulsarius.Incidents.Incident
  alias Pulsarius.Monitoring.Monitor
  alias PulsariusWeb.SlackView

  @type t :: %__MODULE__{type: atom, webhook_url: String.t(), body: String.t()}
  @type incident :: Incident.t()
  @type webhook_url :: String.t()
  @type webhook_urls :: [String.t()]
  @type monitor :: Monitor.t()

  defstruct [:type, :webhook_url, :body]

  @spec incident_created(incident) :: [Slack.t()]
  def incident_created(incident) do
    body = SlackView.render_body("incident_created.json", incident)
    webhook_urls = get_webhook_urls(incident)

    build_notifications(:incident_created, webhook_urls, body)
  end

  @spec incident_auto_resolved(incident) :: [Slack.t()]
  def incident_auto_resolved(incident) do
    body = SlackView.render_body("incident_auto_resolved.json", incident)
    webhook_urls = get_webhook_urls(incident)

    build_notifications(:incident_auto_resolved, webhook_urls, body)
  end

  @spec incident_resolved(%{incident: Incident.t(), user: User.t()}) :: [Slack.t()]
  def incident_resolved(%{incident: incident, user: _user} = args) do
    body = SlackView.render_body("incident_resolved.json", args)
    webhook_urls = get_webhook_urls(incident)

    build_notifications(:incident_resolved, webhook_urls, body)
  end

  @spec incident_acknowledged(%{incident: Incident.t(), user: User.t()}) :: [Slack.t()]
  def incident_acknowledged(%{incident: incident, user: _user} = args) do
    body = SlackView.render_body("incident_acknowledged.json", args)
    webhook_urls = get_webhook_urls(incident)

    build_notifications(:incident_acknowledged, webhook_urls, body)
  end

  @spec monitor_paused(%{monitor: Monitor.t(), user: User.t()}) :: [Slack.t()]
  def monitor_paused(%{monitor: monitor, user: _user} = args) do
    body = SlackView.render_body("monitor_paused.json", args)
    webhook_urls = get_webhook_urls(monitor)

    build_notifications(:monitor_paused, webhook_urls, body)
  end

  @spec monitor_unpaused(%{monitor: Monitor.t(), user: User.t()}) :: [Slack.t()]
  def monitor_unpaused(%{monitor: monitor, user: _user} = args) do
    body = SlackView.render_body("monitor_unpaused.json", args)
    webhook_urls = get_webhook_urls(monitor)

    build_notifications(:monitor_unpaused, webhook_urls, body)
  end

  defp build_notifications(type, webhook_urls, body) do
    webhook_urls
    |> Enum.map(&build_template(type, &1, body))
  end

  defp build_template(type, webhook_url, body) do
    %__MODULE__{type: type, webhook_url: webhook_url, body: body}
  end

  defp get_webhook_urls(%Incident{} = incident) do
    extract_webhook_urls_from(incident.monitor)
  end

  defp get_webhook_urls(%Monitor{} = monitor) do
    extract_webhook_urls_from(monitor)
  end

  defp extract_webhook_urls_from(resource) do
    Pulsarius.Repo.preload(resource, :slack_integrations)
    |> Map.get(:slack_integrations)
    |> Enum.map(& &1.webhook_url)
  end

  defimpl Pulsarius.Notifications.Notification, for: Pulsarius.Notifications.Webhooks.Slack do
    alias Pulsarius.Notifications.Webhooks

    @spec send(%{args: list, body: String.t()}) :: :ok
    def send(%{webhook_url: _webhook_url, body: _body} = slack_notification) do
      Webhooks.deliver(slack_notification)
    end
  end
end
