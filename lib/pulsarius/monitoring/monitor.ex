defmodule Pulsarius.Monitoring.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monitoring" do


    timestamps()
  end

  @doc false
  def changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [])
    |> validate_required([])
  end
end
