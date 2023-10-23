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

  @spec incident_auto_resolved(Incident.t()) :: :ok
  def incident_resolved(args) do
    webhook_notifications = Webhooks.notifications_for(:incident_resolved, args)
    email_notifications = Email.notifications_for(:incident_resolved, args)

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
  def monitor_unpaused(args) do
    webhook_notifications = Webhooks.notifications_for(:monitor_unpaused, args)

    webhook_notifications
    |> Enum.map(&Notification.send/1)
  end

  @spec monitor_unpaused(Monitor.t()) :: :ok
  def incident_acknowledged(args) do
    webhook_notifications = Webhooks.notifications_for(:incident_acknowledged, args)

    webhook_notifications
    |> Enum.map(&Notification.send/1)
  end

  @spec user_invitation_created(UserInvitation.t()) :: :ok
  def user_invitation_created(invitation) do
    Email.notifications_for(:user_invitation_created, invitation)
    |> Notification.send()
  end

  @spec send_test_alert(%{user: User.t(), monitor: Monitor.t()}) :: :ok
  def send_test_alert(args) do
    Email.notifications_for(:send_test_alert, args)
    |> Notification.send()
  end

  @spec send_magic_link(%{email: String.t(), link: String.t()}) :: :ok
  def send_magic_link(args) do
    Email.notifications_for(:send_magic_link, args)
    |> Notification.send()
  end
end
