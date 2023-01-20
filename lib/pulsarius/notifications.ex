defmodule Pulsarius.Notifications do
   alias   Pulsarius.Notifications.Email

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
    email = Email.incident_created(%{}, %{})
    Notification.send(email)
    # recipients
    # |> Enum.map(&Email.incident_created(incident, &1))
    # |> Enum.each(&Notification.send/1)
  end

  @spec incident_auto_resolved(Incident.t(), String.t()) :: :ok
  def incident_auto_resolved(incident, recipients) do
    email = Email.incident_auto_resolved(%{}, %{})
    Notification.send(email)
    # recipients
    # |> Enum.map(&Email.incident_created(incident, &1))
    # |> Enum.each(&Notification.send/1)
  end
end
