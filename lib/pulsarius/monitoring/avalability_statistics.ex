defmodule Pulsarius.Monitoring.AvailabilityStatistics do
  @moduledoc """
  Provides calculation of availability statistics over different time periods using service incident records.
  """

  use Timex

  defstruct [:today, :weekly, :monthly, :annual]

  @day_ranges %{today: 0, weekly: -7, monthly: -30, annual: -365}

  @type t :: %__MODULE__{
          today: map(),
          weekly: map(),
          monthly: map(),
          annual: map()
        }

  @spec calculate([Incident.t()]) :: __MODULE__.t()
  def calculate(incidents) do
    periods = [
      today: 1440,
      weekly: 10080,
      monthly: 43200,
      annual: 525_600
    ]

    Enum.reduce(periods, %__MODULE__{}, fn {period, minutes}, acc ->
      Map.put(acc, period, calculate_stats(incidents, period, minutes))
    end)
  end

  def calculate_average_response_time(status_response) when length(status_response) == 0, do: 0

  def calculate_average_response_time(status_response) do
    sum_of_all_ms = Enum.map(status_response, & &1.response_time_in_ms) |> Enum.sum()
    number_of_status_responses = Enum.count(status_response)

    (sum_of_all_ms / number_of_status_responses) |> Float.ceil(1)
  end

  defp calculate_stats(incidents, period, total_minutes) do
    period_incidents = incidents_for_range(incidents, period)
    availability = calculate_availability(period_incidents, total_minutes)

    %{
      availability_percentage: availability,
      downtime_minutes: calculate_unavailability_minutes(period_incidents),
      incident_count: length(period_incidents),
      longest_incident_duration: longest_incident_duration(period_incidents)
    }
  end

  defp incidents_for_range(incidents, period) do
    today = Timex.today()
    from = Timex.shift(today, days: Map.fetch!(@day_ranges, period))
    until = Timex.end_of_day(today)

    Enum.filter(incidents, &in_date_range?(&1, from, until))
  end

  defp in_date_range?(incident, from, until) do
    occurrence_time = incident.occured_at
    from <= occurrence_time and occurrence_time <= until
  end

  defp calculate_availability(incidents, total_minutes) do
    unavailability = calculate_unavailability_minutes(incidents)
    Float.round((total_minutes - unavailability) / total_minutes * 100, 2)
  end

  defp calculate_unavailability_minutes(incidents) do
    Enum.reduce(incidents, 0, fn incident, acc ->
      duration = Timex.diff(incident.resolved_at || Timex.now(), incident.occured_at, :minutes)
      acc + duration
    end)
  end

  defp longest_incident_duration(incidents) do
    incidents
    |> Enum.map(&Timex.diff(&1.resolved_at || Timex.now(), &1.occured_at, :minutes))
    # |> IO.inspect()
    |> Enum.max(fn -> 0 end)
  end
end
