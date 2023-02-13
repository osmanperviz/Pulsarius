defmodule Pulsarius.Notifications do
  alias Pulsarius.Notifications.{Webhooks, Email}

  defprotocol Notification do
    @moduledoc """
    A protocol for dealing with the
    various forms of notifications.
    """
    @doc "Sends a notification."
    def send(notification)
  end

  @spec incident_created(Incident.t()) :: :ok
  def incident_created(incident) do
    webhook_notifications = Webhooks.notifications_for(:incident_created, incident)
    email_notifications = Email.notifications_for(:incident_created, incident)

    (webhook_notifications ++ email_notifications)
    |> Enum.map(&Notification.send/1)
  end

  @spec incident_auto_resolved(Incident.t()) :: :ok
  def incident_auto_resolved(incident) do
    webhook_notifications = Webhooks.notifications_for(:incident_auto_resolved, incident)
    email_notifications = Email.notifications_for(:incident_auto_resolved, incident)

    (webhook_notifications ++ email_notifications)
    |> Enum.map(&Notification.send/1)
  end

  @spec monitor_paused(Monitor.t()) :: :ok
  def monitor_paused(monitor) do
    webhook_notifications = Webhooks.notifications_for(:monitor_paused, monitor)

    webhook_notifications
    |> Enum.map(&Notification.send/1)
  end

    @spec monitor_unpaused(Monitor.t()) :: :ok
  def monitor_unpaused(monitor) do
    webhook_notifications = Webhooks.notifications_for(:monitor_unpaused, monitor)

    webhook_notifications
    |> Enum.map(&Notification.send/1)
  end

  @spec user_invitation_created(UserInvitation.t()) :: :ok
  def user_invitation_created(invitation) do
    Email.notifications_for(:user_invitation_created, invitation)
    |> Notification.send()
  end
end
