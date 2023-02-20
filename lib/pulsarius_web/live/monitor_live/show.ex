defmodule PulsariusWeb.MonitorLive.Show do
  use PulsariusWeb, :live_view
  use Timex

  alias Pulsarius.Monitoring
  alias Pulsarius.Incidents

  import PulsariusWeb.MonitorLive.AddSlackIntegrationComponent
  import PulsariusWeb.MonitorLive.MonitoringComponents

  @topic "monitor"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    number_of_incidents = Incidents.list_incidents(id) |> Enum.count()
    period = dates_for_period("day")

    {:noreply,
     socket
     |> assign(:monitor, Monitoring.get_monitor!(id))
     |> assign(:number_of_incidents, number_of_incidents)
     |> assign(:selected_period, "day")
     |> push_event("response_time", %{
       response_time: response_time_for_chart(id, period.from, period.to)
     })}
  end

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

    :ok = Pulsarius.EndpointChecker.update_state(monitor)
    Pulsarius.broadcast(@topic, {:monitor_paused, monitor})

    {:noreply, assign(socket, :monitor, monitor)}
  end

  def handle_event("unpause-monitoring", _params, %{assigns: assigns} = socket) do
    {:ok, monitor} = Monitoring.update_monitor(assigns.monitor, %{status: "active"})

    :ok = Pulsarius.EndpointChecker.update_state(monitor)

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
