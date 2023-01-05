defmodule Pulsarius.Monitoring.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monitoring" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
