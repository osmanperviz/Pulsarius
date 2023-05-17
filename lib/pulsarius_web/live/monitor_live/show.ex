defmodule PulsariusWeb.MonitorLive.Show do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring
  alias Pulsarius.Incidents
  alias Pulsarius.Monitoring.AvalabilityStatistics
  alias PulsariusWeb.MonitorLive.{TotalAvailabilityWidget, CheckedAtWidget}

  import PulsariusWeb.MonitorLive.AddSlackIntegrationComponent
  import PulsariusWeb.MonitorLive.MonitoringComponents

  @topic "monitor"

  @impl true
  def mount(_params, _session, socket) do
    Pulsarius.subscribe("incidents")
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
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
  # @impl true
  # def handle_info({:incident_created, payload}, %{assigns: %{monitor: monitor}} = socket) when payload.monitor_id == monitor.id do
  #   incidents = Incidents.list_incidents(monitor.id)
  #   monitor = Monitoring.get_monitor!(monitor.id) |> Pulsarius.Repo.preload(:active_incident)
  #   most_recent_status_response = Monitoring.get_most_recent_status_response!(monitor.id)

  #   IO.inspect(monitor.status, label: "incident_created: =========================>")

  #   {:noreply,
  #    socket
  #    |> assign(:monitor, monitor)
  #    |> assign(:number_of_incidents, Enum.count(incidents))
  #    |> assign(:last_incident, List.last(incidents))
  #    |> assign(:active_incident, monitor.active_incident)
  #    |> assign(:most_recent_status_response, most_recent_status_response)}

  # end

  # @doc """
  # Handle incoming events from endpoint_checker.
  # """
  # @impl true
  # def handle_info({:incident_auto_resolved, payload}, %{assigns: %{monitor: monitor}} = socket) when payload.monitor_id == monitor.id do
  #   incidents = Incidents.list_incidents(monitor.id)
  #   monitor = Monitoring.get_monitor!(monitor.id) |> Pulsarius.Repo.preload(:active_incident)
  #   most_recent_status_response = Monitoring.get_most_recent_status_response!(monitor.id)

  #   IO.inspect(monitor.status, label: "incident_auto_resolved: =========================>")

  #   socket = socket
  #    |> assign(:monitor, monitor)
  #   #  |> assign(:number_of_incidents, Enum.count(incidents))
  #   #  |> assign(:last_incident, List.last(incidents))
  #   #  |> assign(:active_incident, monitor.active_incident)
  #   #  |> assign(:most_recent_status_response, most_recent_status_response)

  #   {:noreply, socket}

  # end

  def handle_event("change-date-range", %{"period" => period}, socket) do
    result = dates_for_period(period)

    socket =
      socket
      |> assign(:selected_period, period)
      |> push_event("response_time", %{
        response_time: response_time_for_chart(socket.assigns.monitor.id, result.from, result.to)
      })

    {:noreply, socket}
  end

  @impl true
  def handle_event("pause-monitoring", _params, %{assigns: assigns} = socket) do
    {:ok, monitor} = Monitoring.update_monitor(assigns.monitor, %{status: "paused"})

    :ok = Pulsarius.UrlMonitor.update_state(monitor)
    Pulsarius.broadcast(@topic, {:monitor_paused, monitor})

    {:noreply, assign(socket, :monitor, monitor)}
  end

  def handle_event("unpause-monitoring", _params, %{assigns: assigns} = socket) do
    {:ok, monitor} = Monitoring.update_monitor(assigns.monitor, %{status: "active"})

    :ok = Pulsarius.UrlMonitor.update_state(monitor)

    Pulsarius.broadcast(@topic, {:monitor_unpaused, monitor})

    {:noreply, assign(socket, :monitor, monitor)}
  end

  def handle_event("send-test-alert", _params, %{assigns: assigns} = socket) do
    Pulsarius.broadcast(@topic, {:send_test_alert, assigns.current_user})

    socket =
      put_flash(
        socket,
        :info,
        "We sent you a test alert. Don't worry, your colleagues were not notified."
      )

    {:noreply, socket}
  end

  defp response_time_for_chart(monitor_id, from, to) do
    Monitoring.list_status_responses(monitor_id, from, to)
    |> Enum.map(fn status_response ->
      %{
        x: NaiveDateTime.to_time(status_response.occured_at),
        y: status_response.response_time_in_ms
      }
    end)
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
