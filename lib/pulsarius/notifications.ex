defmodule Pulsarius.Notifications do
  alias Pulsarius.Notifications.{NotificationBuilder, Email}

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
    NotificationBuilder.build_for(:incident_created, incident)
    |> Enum.map(&Notification.send/1)
  end

  @spec incident_auto_resolved(Incident.t()) :: :ok
  def incident_auto_resolved(incident) do
    NotificationBuilder.build_for(:incident_auto_resolved, incident)
    |> Enum.map(&Notification.send/1)
  end

  @spec user_invitation_created(UserInvitation.t()) :: :ok
  def user_invitation_created(invitation) do
    Email.user_invitation_created(invitation, invitation.email)
    |> Notification.send()
  end
end
