defmodule Pulsarius.Monitoring.Monitor do
  @moduledoc """
  Represent an entity that needs to be monitored
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Pulsarius.Configurations.Configuration
  alias Pulsarius.Incidents.Incident
  alias Pulsarius.Accounts.Account
  alias Pulsarius.Monitoring.StatusResponse

  @type t :: %__MODULE__{
          name: String.t(),
          status: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "monitoring" do
    field :name, :string

    field :status, Ecto.Enum,
      values: [:initializing, :active, :inactive, :paused],
      default: :initializing

    has_one :configuration, Configuration, on_replace: :delete
    has_one :active_incident, Incident, where: [status: :active]

    belongs_to :account, Account,
      foreign_key: :account_id,
      type: :binary_id

    has_many :users, through: [:account, :users]
    has_many :incidents, Incident, on_replace: :delete
    has_many :status_response, StatusResponse, on_replace: :delete

    field :statistics, :map, virtual: true

    timestamps()
  end

  @doc false
  def changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [:name, :status])
    |> validate_required([:name])
    |> cast_assoc(:configuration)
  end

  @spec ssl_check?(Monitor.t()) :: boolean()
  def ssl_check?(monitor) do
    monitor.configuration.ssl_notify_before_in_days != nil
  end

  @spec with_active_state_and_active_incident(Ecto.Queryable.t()) :: Ecto.Query.t()
  def with_active_state_and_active_incident(queryable \\ __MODULE__) do
    from m in queryable,
      # TODO: define what is active state
      where: m.status in [:initializing, :active, :inactive, :paused],
      preload: [:configuration, :active_incident]
  end

  def cast_statistics(monitor, statistics) do
    %__MODULE__{monitor | statistics: statistics}
  end
end

# https://hooks.slack.com/services/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
# https://review-app.gigalixirapp.com/health-check
