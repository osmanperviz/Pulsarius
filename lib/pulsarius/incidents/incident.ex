defmodule Pulsarius.Incidents.Incident do
  @moduledoc """
  When monitor service is unavailable this module holding data related to this event 
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Monitoring.Monitor

  @type t :: %__MODULE__{
          occured_at: String.t(),
          page_response: String.t(),
          resolved_at: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "incidents" do
    field :occured_at, :utc_datetime_usec
    field :page_response, :string
    field :resolved_at, :utc_datetime_usec
    field :status, Ecto.Enum, values: [:active, :resolved], default: :active

    belongs_to :monitor, Monitor,
      foreign_key: :monitor_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [:occured_at, :resolved_at, :page_response, :status])
    |> validate_required([:occured_at])
  end
end
