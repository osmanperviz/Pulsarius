defmodule PulsariusWeb.MonitorLive.Show do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring
  import PulsariusWeb.MonitorLive.AddSlackIntegrationComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:monitor, Monitoring.get_monitor!(id))}
  end

  @impl true
  def handle_event("pause-monitoring", _params, %{assigns: assigns} = socket) do
    {:ok, monitor} = Monitoring.update_monitor(assigns.monitor, %{status: "paused"})

    :ok = Pulsarius.EndpointChecker.update_state(monitor)

    {:noreply, assign(socket, :monitor, monitor)}
  end

  def handle_event("unpause-monitoring", _params, %{assigns: assigns} = socket) do
    {:ok, monitor} = Monitoring.update_monitor(assigns.monitor, %{status: "active"})

    :ok = Pulsarius.EndpointChecker.update_state(monitor)

    {:noreply, assign(socket, :monitor, monitor)}
  end
end
