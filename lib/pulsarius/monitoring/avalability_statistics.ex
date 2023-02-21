defmodule Pulsarius.Monitoring.AvalabilityStatistics do
  @moduledoc """
  This module's responsibility is to calculate availability statistics for various time periods 
  based on incidents that are created when service becomes unavailable
  """
  use Timex

  # TODO: REFACTURE

  defstruct [:todays_statistics, :weekly_statistics, :monthly_statistics, :annual_statistics]

  @type t :: %__MODULE__{
          todays_statistics: map(),
          weekly_statistics: map(),
          monthly_statistics: map(),
          annual_statistics: map()
        }

  @spec calculate(list(Incident.t())) :: __MODULE__.t()
  def calculate(incidents) do
    %__MODULE__{
      todays_statistics: calculate_todays_stats(incidents),
      weekly_statistics: calculate_weekly_stats(incidents),
      monthly_statistics: calculate_monthly_stats(incidents),
      annual_statistics: calculate_annual_stats(incidents)
    }
  end

  defp calculate_todays_stats(incidents) do
    # total number of minutes in one day
    total_numbers_of_minutes = 1440
    todays_incidents = incidents_for_date_range(incidents, todays_range())

    avalability_in_percentage = calculate_avalability(todays_incidents, total_numbers_of_minutes)
    total_down_time = calculate_total_downtime(todays_incidents)
    longest_incident_duration_in_minutes = calculate_longest_incident_duration(todays_incidents)

    %{
      total_avalability_in_percentage: avalability_in_percentage,
      total_down_time_in_minutes: total_down_time,
      number_of_incidents: Enum.count(todays_incidents),
      longest_incident_duration_in_minutes: longest_incident_duration_in_minutes
    }
  end

  def calculate_weekly_stats(incidents) do
    #   total number of minutes in one week
    total_numbers_of_minutes = 10080
    week_incidents = incidents_for_date_range(incidents, week_range())

    avalability_in_percentage = calculate_avalability(week_incidents, total_numbers_of_minutes)
    total_down_time = calculate_total_downtime(week_incidents)
    longest_incident_duration_in_minutes = calculate_longest_incident_duration(week_incidents)

    %{
      total_avalability_in_percentage: avalability_in_percentage,
      total_down_time_in_minutes: total_down_time,
      number_of_incidents: Enum.count(week_incidents),
      longest_incident_duration_in_minutes: longest_incident_duration_in_minutes
    }
  end

  def calculate_monthly_stats(incidents) do
    # total number of minutes in one month
    total_numbers_of_minutes = 43200
    month_incidents = incidents_for_date_range(incidents, month_range())

    avalability_in_percentage = calculate_avalability(month_incidents, total_numbers_of_minutes)
    total_down_time = calculate_total_downtime(month_incidents)
    longest_incident_duration_in_minutes = calculate_longest_incident_duration(month_incidents)

    %{
      total_avalability_in_percentage: avalability_in_percentage,
      total_down_time_in_minutes: total_down_time,
      number_of_incidents: Enum.count(month_incidents),
      longest_incident_duration_in_minutes: longest_incident_duration_in_minutes
    }
  end

  def calculate_annual_stats(incidents) do
    # total number of minutes in one year
    total_numbers_of_minutes = 525_600
    anual_incidents = incidents_for_date_range(incidents, annual_range())

    avalability_in_percentage = calculate_avalability(anual_incidents, total_numbers_of_minutes)
    total_down_time = calculate_total_downtime(anual_incidents)
    longest_incident_duration_in_minutes = calculate_longest_incident_duration(anual_incidents)

    %{
      total_avalability_in_percentage: avalability_in_percentage,
      total_down_time_in_minutes: total_down_time,
      number_of_incidents: Enum.count(anual_incidents),
      longest_incident_duration_in_minutes: longest_incident_duration_in_minutes
    }
  end

  defp calculate_longest_incident_duration(incidents) do
    incidents
    |> Enum.reduce(0, fn incident, acc ->
      duration_in_minutes = Timex.diff(incident.resolved_at, incident.occured_at, :minutes)
      if duration_in_minutes > acc, do: duration_in_minutes, else: acc
    end)
  end

  defp calculate_total_downtime(incidents) do
    number_of_minutes = calculate_unavailability_in_minutes(incidents)
  end

  defp incidents_for_date_range(incidents, date_range) do
    Enum.filter(incidents, fn incident ->
      incident.occured_at in date_range
    end)
  end

  defp calculate_avalability(incidents, total_numbers_of_minutes) do
    calculate_unavailability_in_minutes(incidents)
    |> calculate_avalability_in_percentage(total_numbers_of_minutes)
  end

  defp calculate_avalability_in_percentage(unavailability_in_minutes, numbers_of_total_minutes) do
    ((numbers_of_total_minutes - unavailability_in_minutes) / numbers_of_total_minutes * 100)
    |> Float.ceil(4)
  end

  defp calculate_unavailability_in_minutes(incidents) do
    Enum.reduce(incidents, 0, fn incident, acc ->
      duration = Timex.diff(incident.resolved_at, incident.occured_at, :minutes)
      acc = acc + duration
      acc
    end)
  end

  defp todays_range() do
    until = today() |> Timex.end_of_day()

    Interval.new(from: today(), until: until)
  end

  defp week_range() do
    from = today() |> Timex.shift(days: -7)
    until = Timex.now() |> Timex.end_of_day()

    Interval.new(from: from, until: until)
  end

  defp month_range() do
    from = today() |> Timex.shift(days: -30)
    until = Timex.now() |> Timex.end_of_day()

    Interval.new(from: from, until: until)
  end

  defp annual_range() do
    from = today() |> Timex.shift(days: -365)
    until = Timex.now() |> Timex.end_of_day()

    Interval.new(from: from, until: until)
  end

  defp today(), do: Timex.now() |> Timex.beginning_of_day()
end

# Timex.format_duration(%Timex.Duration{seconds: 600, megaseconds: 0, microseconds: 0}, :humanized) 
