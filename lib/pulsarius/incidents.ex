defmodule Pulsarius.Incidents do
  @moduledoc """
  The Incidents context.
  """

  import Ecto.Query, warn: false
  alias Pulsarius.Repo

  alias Pulsarius.Incidents.Incident

  @doc """
  Returns the list of incidents for given monitoring.

  ## Examples

      iex> list_incidents(monitor_id)
      [%Incident{}, ...]

  """
  def list_incidents(monitor_id) do
    Incident |> where(monitor_id: ^monitor_id) |> order_by(asc: :inserted_at) |> Repo.all()
  end

  @doc """
  Gets a single incident.

  Raises `Ecto.NoResultsError` if the Incident does not exist.

  ## Examples

      iex> get_incident!(123)
      %Incident{}

      iex> get_incident!(456)
      ** (Ecto.NoResultsError)

  """
  def get_incident!(id), do: Repo.get!(Incident, id)

  @doc """
  Creates a incident.

  ## Examples

      iex> create_incident(%{field: value})
      {:ok, %Incident{}}

      iex> create_incident(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_incident(monitor, attrs \\ %{}) do
    %Incident{occured_at: DateTime.utc_now()}
    |> Incident.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:monitor, monitor)
    |> Repo.insert()
  end

  @doc """
  Updates a incident.

  ## Examples

      iex> update_incident(incident, %{field: new_value})
      {:ok, %Incident{}}

      iex> update_incident(incident, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_incident(%Incident{} = incident, attrs) do
    incident
    |> Incident.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a incident.

  ## Examples

      iex> delete_incident(incident)
      {:ok, %Incident{}}

      iex> delete_incident(incident)
      {:error, %Ecto.Changeset{}}

  """
  def delete_incident(%Incident{} = incident) do
    Repo.delete(incident)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking incident changes.

  ## Examples

      iex> change_incident(incident)
      %Ecto.Changeset{data: %Incident{}}

  """
  def change_incident(%Incident{} = incident, attrs \\ %{}) do
    Incident.changeset(incident, attrs)
  end

  @doc """
  Auto resolve incident(set status to :resolved).

  ## Examples

      iex> auto_resolve(incident)
      {:ok, %Incident{}}

      iex> auto_resolve(incident)
      {:error, %Ecto.Changeset{}}

  """
  def auto_resolve(%Incident{} = incident) do
    update_incident(incident, %{status: :resolved, resolved_at: NaiveDateTime.utc_now()})
  end

  def get_most_recent_incident!(monitor_id) do
    Incident |> where(monitor_id: ^monitor_id) |> last(:inserted_at) |> Repo.one()
  end
end
