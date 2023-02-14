defmodule PulsariusWeb.MonitorLive.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :monitoring, Monitoring.list_monitoring())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    monitor = Monitoring.get_monitor!(id)
    {:ok, _} = Monitoring.delete_monitor(monitor)

    # stop related running monitor process
    Pulsarius.EndpointChecker.stop_monitoring(monitor)

    {:noreply, assign(socket, :monitoring, Monitoring.list_monitoring())}
  end
end
