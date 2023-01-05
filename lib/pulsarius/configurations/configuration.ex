defmodule Pulsarius.Configurations.Configuration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Monitoring.Monitor

  schema "configuration" do
    field :frequency_check_in_seconds, :integer
    field :url_to_monitor, :string

    belongs_to :monitor, Monitor, type: :binary_id, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(configuration, attrs) do
    configuration
    |> cast(attrs, [:url_to_monitor, :frequency_check_in_seconds])
    |> validate_required([:url_to_monitor, :frequency_check_in_seconds])
  end
end
