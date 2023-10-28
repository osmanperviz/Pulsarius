defmodule PulsariusWeb.MonitorLive.Show do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring
  alias Pulsarius.Incidents
  alias Pulsarius.Monitoring.{AvalabilityStatistics, StatusResponse, Monitor}
  alias PulsariusWeb.MonitorLive.{TotalAvailabilityWidget, CheckedAtWidget}

  import PulsariusWeb.MonitorLive.MonitoringComponents
  import PulsariusWeb.CoreComponents

  @topic "monitor"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    :ok = Pulsarius.subscribe("monitor:" <> id)
    incidents = Incidents.list_incidents(id)
    period = dates_for_period("day")
    avalability_statistics = AvalabilityStatistics.calculate(incidents)
    monitor = Monitoring.get_monitor!(id) |> Pulsarius.Repo.preload(:active_incident)
    most_recent_status_response = Monitoring.get_most_recent_status_response!(id)

    {:noreply,
     socket
     |> assign(:monitor, monitor)
     |> assign(:number_of_incidents, Enum.count(incidents))
     |> assign(:selected_period, "day")
     |> assign(:avalability_statistics, avalability_statistics)
     |> assign(:last_incident, List.last(incidents))
     |> assign(:active_incident, monitor.active_incident)
     |> assign(:most_recent_status_response, most_recent_status_response)
     |> push_event("response_time", %{
       response_time: response_time_for_chart(id, period.from, period.to)
     })}
  end

  def handle_info(:update_availability_time, socket) do
    monitor = socket.assigns.monitor

    send_update(TotalAvailabilityWidget,
      monitor: monitor,
      id: monitor.id,
      last_incident: socket.assigns.last_incident,
      active_incident: socket.assigns.active_incident
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info(:tick, %{assigns: assigns} = socket) do
    send_update(CheckedAtWidget,
      monitor: assigns.monitor,
      id: assigns.monitor.id,
      last_status_response: assigns.most_recent_status_response
    )

    {:noreply, socket}
  end

  # @doc """
  # Handle incoming events from endpoint_checker.
  # """
  def handle_info(%StatusResponse{} = status_response, %{assigns: assigns} = socket) do
    IO.inspect("HIT status response =============>")

    {:noreply,
     socket
     |> assign(:most_recent_status_response, status_response)}
  end

  # @doc """
  # Handle incoming events from endpoint_checker.
  # """
  def handle_info(%Monitor{} = monitor, %{assigns: assigns} = socket) do
    incidents = Incidents.list_incidents(monitor.id)
    avalability_statistics = AvalabilityStatistics.calculate(incidents)
    monitor = Pulsarius.Repo.preload(monitor, :active_incident)
    most_recent_status_response = Monitoring.get_most_recent_status_response!(monitor.id)

    {:noreply,
     socket
     |> assign(:monitor, monitor)
     |> assign(:number_of_incidents, Enum.count(incidents))
     |> assign(:avalability_statistics, avalability_statistics)
     |> assign(:last_incident, List.last(incidents))
     |> assign(:active_incident, monitor.active_incident)
     |> assign(:most_recent_status_response, most_recent_status_response)}
  end

  def handle_event("change-date-range", %{"period" => period}, socket) do
    result = dates_for_period(period)

    socket =
      socket
      |> assign(:selected_period, period)
      |> push_event("response_time", %{
        response_time:
          response_time_for_chart(socket.assigns.monitor.id, result.from, result.to, period)
      })

    {:noreply, socket}
  end

  @impl true
  def handle_event("pause-monitoring", _params, %{assigns: assigns} = socket) do
    {:ok, monitor} = Monitoring.update_monitor(assigns.monitor, %{status: "paused"})

    :ok = Pulsarius.UrlMonitor.update_state(monitor)

    Pulsarius.broadcast(
      @topic,
      {:monitor_paused, %{monitor: monitor, user: assigns.current_user}}
    )

    {:noreply, assign(socket, :monitor, monitor)}
  end

  def handle_event("unpause-monitoring", _params, %{assigns: assigns} = socket) do
    {:ok, monitor} = Monitoring.update_monitor(assigns.monitor, %{status: "active"})

    :ok = Pulsarius.UrlMonitor.update_state(monitor)

    Pulsarius.broadcast(
      @topic,
      {:monitor_unpaused, %{monitor: monitor, user: assigns.current_user}}
    )

    {:noreply, assign(socket, :monitor, monitor)}
  end

  def handle_event("send-test-alert", _params, %{assigns: assigns} = socket) do
    Pulsarius.broadcast(
      @topic,
      {:send_test_alert, %{user: assigns.current_user, monitor: assigns.monitor}}
    )

    socket =
      put_flash(
        socket,
        :info,
        "We sent you a test alert. Don't worry, your colleagues were not notified."
      )

    {:noreply, socket}
  end

  defp response_time_for_chart(monitor_id, from, to, period \\ "day") do
    response_data = Monitoring.list_status_responses(monitor_id, from, to)

    # Group the response data by week or month
    grouped_data = group_data(response_data, period)

    # Calculate aggregated values for each week or month
    aggregated_data = calculate_aggregates(grouped_data)

    # Transform the aggregated data for chart rendering
    transform_data(aggregated_data)
  end

  defp group_by_two_hours(response_data) do
    Enum.group_by(response_data, fn record ->
      week_start = Timex.beginning_of_week(record.occured_at)
      elapsed_hours = Timex.diff(record.occured_at, week_start, :hours)
      grouped_hours = div(elapsed_hours, 2) * 2
      Timex.shift(week_start, hours: grouped_hours)
    end)
  end

  defp group_by_two_minutes(response_data) do
    Enum.group_by(response_data, fn record ->
      day_start = Timex.beginning_of_day(record.occured_at)
      elapsed_minutes = Timex.diff(record.occured_at, day_start, :minutes)
      grouped_minutes = div(elapsed_minutes, 2) * 2
      Timex.shift(day_start, minutes: grouped_minutes)
    end)
  end

  defp group_by_twelve_hours(response_data) do
    Enum.group_by(response_data, fn record ->
      month_start = Timex.beginning_of_month(Timex.now())
      elapsed_hours = Timex.diff(record.occured_at, month_start, :hours)
      grouped_hours = div(elapsed_hours, 12) * 12
      Timex.shift(month_start, hours: grouped_hours)
    end)
  end

  defp transform_data(aggregated_data) do
    transformed_data =
      Enum.map(aggregated_data, fn {date, aggregated_values} ->
        %{
          x: date,
          y: aggregated_values[:average_response_time]
        }
      end)

    sorted_data = Enum.sort_by(transformed_data, & &1.x)

    sorted_data
  end

  defp calculate_aggregates(grouped_data) do
    Enum.reduce(grouped_data, %{}, fn {date, data}, acc ->
      response_times = data |> Enum.map(& &1.response_time_in_ms)
      average_response_time = calculate_average(response_times)

      aggregated_values = %{average_response_time: average_response_time}

      Map.put(acc, date, aggregated_values)
    end)
  end

  defp group_data(response_data, range) do
    case range do
      "day" -> group_by_two_minutes(response_data)
      "week" -> group_by_two_hours(response_data)
      "month" -> group_by_twelve_hours(response_data)
    end
  end

  defp calculate_average(data) do
    case data do
      [] ->
        nil

      _ ->
        sum = Enum.sum(data)
        length = length(data)
        average = sum / length
        rounded_average = Float.round(average, 2)
        rounded_average
    end
  end

  defp dates_for_period(period) do
    cond do
      period == "day" ->
        %{from: Timex.beginning_of_day(Timex.now()), to: Timex.end_of_day(Timex.now())}

      period == "week" ->
        %{from: Timex.beginning_of_week(Timex.now()), to: Timex.end_of_week(Timex.now())}

      period == "month" ->
        date_time = Timex.now() |> Timex.to_datetime("Europe/Paris")
        %{from: Timex.beginning_of_month(date_time), to: Timex.end_of_month(date_time)}
    end
  end
end
