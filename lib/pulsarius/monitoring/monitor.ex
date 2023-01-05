defmodule Pulsarius.Monitoring.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monitoring" do
    field :name, :string
    field :status, Ecto.Enum, values: [:active, :inactive] 

    timestamps()
  end

  @doc false
  def changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [:name, :status])
    |> validate_required([:name])
  end
end
