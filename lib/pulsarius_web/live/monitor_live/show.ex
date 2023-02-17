defmodule PulsariusWeb.MonitorLive.Show do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring
  import PulsariusWeb.MonitorLive.AddSlackIntegrationComponent
  import PulsariusWeb.MonitorLive.MonitoringComponents

  @topic "monitor"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:monitor, Monitoring.get_monitor!(id))
     |> push_event("response_time", %{response_time: prepare_response_time_data_for_chart(id)})}
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

  defp prepare_response_time_data_for_chart(monitor_id) do
    status_responses = Monitoring.list_status_responses(monitor_id)

    status_responses
    |> Enum.map(fn status_response ->
      %{
        x: NaiveDateTime.to_time(status_response.occured_at),
        y: status_response.response_time_in_ms
      }
    end)
  end
end
