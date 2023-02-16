defmodule Pulsarius.Monitoring do
  @moduledoc """
  The Monitoring context.
  """

  import Ecto.Query, warn: false
  alias Pulsarius.Repo

  alias Pulsarius.Monitoring.{Monitor, StatusResponse}

  @doc """
  Returns the list of monitoring.

  ## Examples

      iex> list_monitoring()
      [%Monitor{}, ...]

  """
  def list_monitoring do
    Repo.all(Monitor)
  end

  @doc """
  Gets a single monitor.

  Raises `Ecto.NoResultsError` if the Monitor does not exist.

  ## Examples

      iex> get_monitor!(123)
      %Monitor{}

      iex> get_monitor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_monitor!(id), do: Repo.get!(Monitor, id) |> Repo.preload(:configuration)

  @doc """
  Creates a monitor.

  ## Examples

      iex> create_monitor(%{field: value})
      {:ok, %Monitor{}}

      iex> create_monitor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_monitor(account, attrs \\ %{}) do
    %Monitor{}
    |> Monitor.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:account, account)
    |> Repo.insert()
  end

  @doc """
  Updates a monitor.

  ## Examples

      iex> update_monitor(monitor, %{field: new_value})
      {:ok, %Monitor{}}

      iex> update_monitor(monitor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_monitor(%Monitor{} = monitor, attrs) do
    monitor
    |> Monitor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a monitor.

  ## Examples

      iex> delete_monitor(monitor)
      {:ok, %Monitor{}}

      iex> delete_monitor(monitor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_monitor(%Monitor{} = monitor) do
    Repo.delete(monitor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking monitor changes.

  ## Examples

      iex> change_monitor(monitor)
      %Ecto.Changeset{data: %Monitor{}}

  """
  def change_monitor(%Monitor{} = monitor, attrs \\ %{}) do
    Monitor.changeset(monitor, attrs)
  end

  @doc """
  Returns the list of status responses for given monitor_id.

  ## Examples

      iex> list_status_responses(monitor_id)
      [%StatusResponse{}, ...]

  """
  def list_status_responses(monitor_id),
    do: StatusResponse |> where(monitor_id: ^monitor_id) |> Repo.all()

  @doc """
   Creates a status response.

  ## Examples

      iex> create_status_response(monitor, %{field: value})
      {:ok, %StatusResponse{}}

      iex> create_status_response(monitor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_status_response(monitor, attrs \\ %{}) do
    %StatusResponse{}
    |> StatusResponse.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:monitoring, monitor)
    |> Repo.insert()
  end
end
