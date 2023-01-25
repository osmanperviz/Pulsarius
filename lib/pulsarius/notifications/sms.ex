defmodule Pulsarius.Notifications.Sms do
  @moduledoc """
    Implementing Notification protocol, responsible for sending different types of SmS notifications.
  """

  defstruct [:type, :args]

  @spec incident_created(Profile.t(), Mailer.recipient()) :: :ok
  def incident_created(incident, recipient) do
    %__MODULE__{type: :incident_created, args: [incident, recipient]}
  end

  defimpl Pulsarius.Notifications.Notification, for: Pulsarius.Notifications.Sms do
    # @spec send(%{type: String.t(), args: list}) :: :ok
    def send(%{type: _type, args: _args}) do
      # implementation
    end
  end
end
