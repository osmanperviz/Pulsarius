defmodule PulsariusWeb.MonitorLive.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :monitoring, list_monitoring())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Monitor")
    |> assign(:monitor, Monitoring.get_monitor!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Monitoring")
    |> assign(:monitor, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    monitor = Monitoring.get_monitor!(id)
    {:ok, _} = Monitoring.delete_monitor(monitor)

    # stop related running monitor process
    Pulsarius.EndpointChecker.stop_monitoring(monitor)

    {:noreply, assign(socket, :monitoring, list_monitoring())}
  end

  defp list_monitoring do
    Monitoring.list_monitoring()
  end
end
