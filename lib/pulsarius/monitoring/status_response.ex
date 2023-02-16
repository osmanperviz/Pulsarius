defmodule Pulsarius.Monitoring.StatusResponse do
  @moduledoc """
  Represent an sucess request -> response cycle that is made by EndpointChecker.
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
end
