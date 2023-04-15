defmodule Pulsarius.Monitoring do
  @moduledoc """
  The Monitoring context.
  """

  import Ecto.Query, warn: false
  alias Pulsarius.Repo

  alias Pulsarius.Monitoring.{Monitor, StatusResponse, AvalabilityStatistics}

  @doc """
  Returns the list of monitoring for given account.

  ## Examples

      iex> list_monitoring(some_account_id)
      [%Monitor{}, ...]

  """
  def list_monitoring(account_id) do
    Monitor
    |> where(account_id: ^account_id)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
    |> Repo.preload([:configuration, :active_incident, :incidents, :status_response])
  end

  def list_monitoring_with_daily_statistics(account_id) do
    list_monitoring(account_id)
    |> Enum.map(fn monitor ->
      statistics =
        Map.merge(AvalabilityStatistics.calculate_todays_stats(monitor.incidents), %{
          average_response_time:
            AvalabilityStatistics.calculate_average_response_time(monitor.status_response)
        })

      Monitor.cast_statistics(monitor, statistics)
    end)
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
    Detecting SSL details/expiry for an given URL and updates Monitor entity

  ## Examples

      iex> set_ssl_expiry(monitor)
      {:ok, %Monitor{}}

      iex> set_ssl_expiry(monitor)
      {:error, %Ecto.Changeset{}}

  """

  def set_ssl_expiry(monitor) do
    {:ok, _valid_from, valid_until} = check_ssl_expiry(monitor.configuration.url_to_monitor)

    params = Map.put(Map.from_struct(monitor.configuration), :ssl_expiry_date, valid_until)

    update_monitor(monitor, %{configuration: params})
  end

  @doc """
   Get a last status response.

  ## Examples

      iex> get_last_status_response!(monitor-id)
      %StatusResponse{}

  """
  def get_most_recent_status_response!(monitor_id) do
    StatusResponse |> where(monitor_id: ^monitor_id) |> last(:inserted_at) |> Repo.one()
  end

  @doc """
  Returns the list of status responses for given monitor_id and given time range.

  ## Examples

      iex> list_status_responses(monitor_id, from, to)
      [%StatusResponse{}, ...]

  """
  def list_status_responses(monitor_id, from, to) do
    StatusResponse.for_monitoring(monitor_id)
    |> StatusResponse.for_date_range(from, to)
    |> StatusResponse.order_by_asc()
    |> Repo.all()
  end

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

  defp check_ssl_expiry(url) do
    uri = URI.parse(url)

    with {:ok, sock} <- :ssl.connect('#{uri.host}', 443, []),
         {:ok, der} <- :ssl.peercert(sock),
         :ssl.close(sock),
         {:ok, cert} <- X509.Certificate.from_der(der),
         {:Validity, valida_from, valid_until} <- X509.Certificate.validity(cert) do
      {:ok, X509.DateTime.to_datetime(valida_from), X509.DateTime.to_datetime(valid_until)}
    end
  end
end
