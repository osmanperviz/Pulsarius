defmodule Pulsarius.Notifications.Email do
  @moduledoc """
    Implementing Notification protocol, responsible for sending different types of Email notifications.
  """
  alias Pulsarius.Mailer
  alias Pulsarius.Accounts.User

  @type t :: %__MODULE__{type: atom, args: list}
  @self __MODULE__

  defstruct [:type, :args, :recipient]

  @spec incident_created(Incident.t()) :: [Email.t()]
  def incident_created(incident),
    do: create_email(:incident_created, incident)

  @spec incident_auto_resolved(Incident.t()) :: [Email.t()]
  def incident_auto_resolved(incident),
    do: create_email(:incident_auto_resolved, incident)

  @spec incident_created(UserInvitation.t()) :: Email.t()
  def user_invitation_created(invitation) do
    %@self{
      type: :user_invitation_created,
      args: %{invitation: invitation},
      recipient: invitation.email
    }
  end

  def notifications_for(type, args) do
    apply(@self, type, [args])
  end

  defp create_email(type, incident) do
    monitor = Pulsarius.Repo.preload(incident.monitor, [:users])

    monitor.users
    |> Enum.map(&format_recipient/1)
    |> Enum.map(&%@self{type: type, args: %{incident: incident}, recipient: &1})
  end

  defp format_recipient(user) do
    {User.full_name(user), user.email}
  end

  defimpl Pulsarius.Notifications.Notification, for: Pulsarius.Notifications.Email do
    alias Pulsarius.Mailer

    @spec send(Email.t()) :: {:ok, term} | {:error, term}
    def send(email) do
      Mailer.deliver(Mailer.to_swoosh_email(email))
    end
  end
end
