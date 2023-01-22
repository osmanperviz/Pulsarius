defmodule Pulsarius.Notifications do
  alias Pulsarius.Notifications.Email
  alias Pulsarius.Monitoring
  alias Pulsarius.Notifications.Webhooks.Slack

  defprotocol Notification do
    @moduledoc """
    A protocol for dealing with the
    various forms of notifications.
    """
    @doc "Sends a notification."
    def send(notification)
  end

  @spec incident_created(Incident.t(), String.t()) :: :ok
  def incident_created(incident, recipients) do
    build_notifications(:incident_created, incident)
    |> Enum.map(&Notification.send/1)

    # email = Email.incident_created(%{}, %{})
    # Notification.send(email)
    # recipients
    # |> Enum.map(&Email.incident_created(incident, &1))
    # |> Enum.each(&Notification.send/1)
  end

  @spec incident_auto_resolved(Incident.t(), String.t()) :: :ok
  def incident_auto_resolved(incident, recipients) do
    build_notifications(:incident_auto_resolved, incident)
    |> Enum.map(&Notification.send/1)

    # email = Email.incident_auto_resolved(%{}, %{})
    # Notification.send(email)
    # # recipients
    # |> Enum.map(&Email.incident_created(incident, &1))
    # |> Enum.each(&Notification.send/1)
  end

  defp build_notifications(type, incident) do
    # TODO: move this to separate MODULE
    []
    |> build_slack_notification(type, incident)
    |> build_email_notification(type, incident)
    |> build_sms_notification(type, incident)
  end

  defp build_slack_notification(notifications, type, incident) do
    slack_notification_enabled = incident.monitor.configuration.slack_notification

    if slack_notification_enabled do
      webhook_url = incident.monitor.configuration.slack_notification_webhook_url
      # notifications ++ [Slack.incident_created(incident, webhook_url)]
      notifications ++ [apply(Slack, type, [incident, webhook_url])]
    else
      notifications
    end
  end

  defp build_email_notification(notifications, type, incident) do
    email_notification_enabled = incident.monitor.configuration.email_notification

    if email_notification_enabled do
      # TODO: for each recipient build email
      # notifications ++ [Email.incident_created(incident, "")]
      notifications ++ [apply(Email, type, [incident, ""])]
    else
      notifications
    end
  end

  defp build_sms_notification(notifications, _type, _incident) do
    # TODO: build sms notification implementation
    notifications
  end
end
