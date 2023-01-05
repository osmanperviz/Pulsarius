defmodule Pulsarius.Configurations.Configuration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Monitoring.Monitor

  @type t :: %__MODULE__{
          frequency_check_in_seconds: String.t(),
          url_to_monitor: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "configuration" do
    field :frequency_check_in_seconds, :string
    field :url_to_monitor, :string

    belongs_to :monitor, Monitor,
      foreign_key: :monitor_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(configuration, attrs) do
    configuration
    |> cast(attrs, [:url_to_monitor, :frequency_check_in_seconds])
    |> validate_required([:url_to_monitor, :frequency_check_in_seconds])
  end
end
