defmodule Pulsarius.Notifications.Email do
  @moduledoc """
    Implementing Notification protocol, responsible for sending different types of Email notifications.
  """
  alias Pulsarius.Mailer

  @type t :: %__MODULE__{type: atom, args: list}

  defstruct [:type, :args]

  @spec incident_created(Profile.t(), Mailer.recipient()) :: :ok
  def incident_created(incident, recipient) do
    %__MODULE__{type: :incident_created, args: [incident, recipient]}
  end

  defimpl Pulsarius.Notifications.Notification, for: Pulsarius.Notifications.Email do
    alias Pulsarius.Mailer

    @spec send(%{type: String.t(), args: list}) :: :ok
    def send(%{type: type, args: args}) do
      Mailer.deliver(apply(Mailer, type, args))
    end
  end
end
