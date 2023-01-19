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

  @spec incident_created(Profile.t(), String.t()) :: :ok
  def incident_created(incident, recipients) do
    email = Email.incident_created(%{}, %{})
    Notification.send(email)
    # recipients
    # |> Enum.map(&Email.incident_created(incident, &1))
    # |> Enum.each(&Notification.send/1)
  end
end
