defmodule Pulsarius.Notifications.NotificationBuilder do
  alias Pulsarius.Notifications.Webhooks.Slack
  alias Pulsarius.Notifications.Email

  def build_for(:incident_created = type, incident) do
    build_slack_notification(type, incident)
    |> build_email_notification(type, incident)
    |> build_sms_notification(type, incident)
  end

  def build_for(:incident_auto_resolved = type, incident) do
    build_slack_notification(type, incident)
    |> build_email_notification(type, incident)
    |> build_sms_notification(type, incident)
  end

  defp build_slack_notification(type, incident) do
    slack_notification_enabled? = incident.monitor.configuration.slack_notification

    if slack_notification_enabled? do
      webhook_url = incident.monitor.configuration.slack_notification_webhook_url
      [apply(Slack, type, [incident, webhook_url])]
    else
      []
    end
  end

  defp build_email_notification(notifications, type, incident) do
    monitor = Pulsarius.Repo.preload(incident.monitor, [:users])

    email_notifications =
      monitor.users
      |> Enum.map(&filter_recipient/1)
      |> Enum.map(&apply(Email, type, [incident, &1]))

    notifications ++ email_notifications
  end

  defp build_sms_notification(notifications, _type, _incident) do
    # TODO: build sms notification implementation
    notifications
  end

  defp filter_recipient(user) do
    {full_name(user), user.email}
  end

  defp full_name(user),
    do: "#{user.first_name} #{user.last_name}"
end
