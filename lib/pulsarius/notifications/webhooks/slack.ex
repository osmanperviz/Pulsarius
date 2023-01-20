defmodule Pulsarius.Notifications.Webhooks.Slack do
  @moduledoc """
    Implementing Notification protocol, responsible for sending different types of Slack notifications.
  """

  @type t :: %__MODULE__{type: atom, args: list}

  defstruct [:type, :args]

  @spec incident_created(Incident.t(), String.t()) :: :ok
  def incident_created(incident, webhook_url) do
    %__MODULE__{type: :incident_created, args: [incident, webhook_url]}
  end

  defimpl Pulsarius.Notifications.Notification, for: Pulsarius.Notifications.Webhooks.Slack do
    alias Pulsarius.Notifications.Webhooks

    @spec send(%{type: String.t(), args: list}) :: :ok
    def send(%{type: type, args: args}) do
      Webhooks.deliver(apply(Webhooks, type, args))
    end
  end
end
