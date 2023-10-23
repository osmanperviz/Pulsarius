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
    do: create_email(:incident_created, %{incident: incident})

  @spec incident_auto_resolved(Incident.t()) :: [Email.t()]
  def incident_auto_resolved(incident),
    do: create_email(:incident_auto_resolved, %{incident: incident})

  @spec incident_resolved(%{incident: Incident.t(), user: User.t()}) :: [Email.t()]
  def incident_resolved(%{incident: _incident, user: _user} = args),
    do: create_email(:incident_auto_resolved, args)

  @spec incident_created(UserInvitation.t()) :: Email.t()
  def user_invitation_created(invitation) do
    %@self{
      type: :user_invitation_created,
      args: %{invitation: invitation},
      recipient: invitation.email
    }
  end

  @spec send_test_alert(%{user: User.t(), monitor: Monitor.t()}) :: Email.t()
  def send_test_alert(args) do
    %@self{
      type: :send_test_alert,
      args: args,
      recipient: args.user.email
    }
  end

  @spec send_magic_link(%{email: String.t(), token: Binary.t()}) :: Email.t()
  def send_magic_link(args) do
    %@self{
      type: :send_magic_link,
      args: args,
      recipient: args.user.email
    }
  end

  def notifications_for(type, args) do
    apply(@self, type, [args])
  end

  defp create_email(type, args) do
    monitor = Pulsarius.Repo.preload(args.incident.monitor, [:users])

    monitor.users
    |> Enum.map(&format_recipient/1)
    |> Enum.map(
      &%@self{type: type, args: Map.merge(args, %{user: &1.user}), recipient: &1.recipient}
    )
  end

  defp format_recipient(user) do
    %{recipient: {User.full_name(user), user.email}, user: user}
  end

  defimpl Pulsarius.Notifications.Notification, for: Pulsarius.Notifications.Email do
    alias Pulsarius.Mailer

    @spec send(Email.t()) :: {:ok, term} | {:error, term}
    def send(email) do
      Mailer.deliver(Mailer.to_swoosh_email(email))
    end
  end
end
