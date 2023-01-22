defmodule Pulsarius.Monitoring.Monitor do
  @moduledoc """
  Represent an entity that needs to be monitored
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Pulsarius.Configurations.Configuration
  alias Pulsarius.Incidents.Incident

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

    timestamps()
  end

  @doc false
  def changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [:name, :status])
    |> validate_required([:name])
    |> cast_assoc(:configuration)
  end

  @spec with_active_state_and_active_incident(Ecto.Queryable.t()) :: Ecto.Query.t()
  def with_active_state_and_active_incident(queryable \\ __MODULE__) do
    from m in queryable,
      # TODO: define what is active state
      where: m.status in [:initializing, :active, :inactive, :paused],
      preload: [:configuration, :active_incident]
  end
end


# https://hooks.slack.com/services/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
# https://review-app.gigalixirapp.com/health-check