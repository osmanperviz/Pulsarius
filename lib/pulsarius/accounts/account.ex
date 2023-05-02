defmodule Pulsarius.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Accounts.User
  alias Pulsarius.Monitoring.Monitor
  alias Pulsarius.Billing.Subscriptions
  alias Pulsarius.Integrations.Integration

  @type t :: %__MODULE__{
          type: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "accounts" do
    field :type, Ecto.Enum, values: [:freelancer, :small_team, :bussines], default: :freelancer
    field :stripe_id, :string
    field :invitation_token, :string

    has_many :users, User, on_replace: :delete
    has_many :monitors, Monitor, on_replace: :delete
    has_many :integrations, Integration, on_replace: :delete

    has_many :slack_integrations, Integration,  where: [type: :slack]
    has_many :ms_teams_integrations, Integration,  where: [type: :ms_teams]

    has_one :subscription, Subscriptions, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:type, :stripe_id, :invitation_token])
    |> validate_required([:type, :invitation_token])
    |> cast_assoc(:users)
  end

  def free_plan?(account) do
    account.subscription == nil
  end
end
