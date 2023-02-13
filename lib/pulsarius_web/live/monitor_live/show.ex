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
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:monitor, Monitoring.get_monitor!(id))}
  end

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
    socket = put_flash(socket, :info, "We sent you a test alert. Don't worry, your colleagues were not notified.")
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Monitor"
  defp page_title(:edit), do: "Edit Monitor"
end
