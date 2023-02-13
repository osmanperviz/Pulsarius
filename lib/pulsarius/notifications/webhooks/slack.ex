defmodule Pulsarius.Notifications.Webhooks.Slack do
  @moduledoc """
    Implementing Notification protocol, responsible for sending and composing different types of Slack notifications.
  """

  alias Pulsarius.Notifications.Webhooks

  @type t :: %__MODULE__{type: atom, webhook_url: String.t(), body: String.t()}
  @type incident :: Incident.t()
  @type webhook_url :: String.t()
  @type monitor :: Monitor.t()

  defstruct [:type, :webhook_url, :body]

  @spec incident_created(incident, webhook_url) :: Slack.t()
  def incident_created(incident, webhook_url) do
    body = Webhooks.render_body(incident, "incident_created.html")

    %__MODULE__{type: :incident_created, webhook_url: webhook_url, body: body}
  end

  @spec incident_auto_resolved(incident, webhook_url) :: Slack.t()
  def incident_auto_resolved(incident, webhook_url) do
    body = Webhooks.render_body(incident, "incident_auto_resolved.html")

    %__MODULE__{type: :incident_auto_resolved, webhook_url: webhook_url, body: body}
  end

  @spec monitor_paused(monitor, webhook_url) :: Slack.t()
  def monitor_paused(monitor, webhook_url) do
    body = Webhooks.render_body(monitor, "monitor_paused.html")

    %__MODULE__{type: :monitor_paused, webhook_url: webhook_url, body: body}
  end

    @spec monitor_unpaused(monitor, webhook_url) :: Slack.t()
  def monitor_unpaused(monitor, webhook_url) do
    body = Webhooks.render_body(monitor, "monitor_unpaused.html")

    %__MODULE__{type: :monitor_paused, webhook_url: webhook_url, body: body}
  end

  defimpl Pulsarius.Notifications.Notification, for: Pulsarius.Notifications.Webhooks.Slack do
    alias Pulsarius.Notifications.Webhooks

    @spec send(%{args: list, body: String.t()}) :: :ok
    def send(%{webhook_url: _webhook_url, body: _body} = slack_notification) do
      Webhooks.deliver(slack_notification)
    end
  end
end
