defmodule Pulsarius.Monitoring.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Configurations.Configuration

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "monitoring" do
    field :name, :string
    field :status, Ecto.Enum, values: [:active, :inactive]

    has_one :configuration, Configuration, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [:name, :status])
    |> validate_required([:name])
    |> cast_assoc(:configuration)
  end
end
