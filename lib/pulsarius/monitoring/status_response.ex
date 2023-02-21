defmodule Pulsarius.Monitoring.StatusResponse do
  @moduledoc """
  Represent an success request -> response cycle that is made by EndpointChecker.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Pulsarius.Monitoring.Monitor

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "status_responses" do
    field :occured_at, :naive_datetime
    field :response_time_in_ms, :integer

    belongs_to :monitoring, Monitor,
      foreign_key: :monitor_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(status_response, attrs) do
    status_response
    |> cast(attrs, [:occured_at, :response_time_in_ms])
    |> validate_required([:occured_at, :response_time_in_ms])
  end

  def for_monitoring(monitor_id) do
    from(
      sr in __MODULE__,
      where: sr.monitor_id == ^monitor_id
    )
  end

  def for_date_range(query, from, to) do
    from(
      sr in query,
      where: sr.occured_at >= ^from,
      where: sr.occured_at <= ^to
    )
  end

  def order_by_asc(query) do
    from(
      sr in query,
      order_by: [asc: :inserted_at]
    )
  end
end
