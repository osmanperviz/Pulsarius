defmodule Pulsarius.Notifications.NotificationServer do
  use GenServer

  alias Pulsarius.Notifications

  def start_link(monitor) do
    GenServer.start_link(__MODULE__, %{}, name: :notification_server)
  end

  def init(state) do
    Pulsarius.subscribe("incidents")

    {:ok, state}
  end

  def handle_info({:incident_created, incident}, socket) do
    Notifications.incident_created(incident, %{})

    {:noreply, socket}
  end

  def handle_info({:incident_auto_resolved, incident}, socket) do
    Notifications.incident_auto_resolved(incident, %{})

    {:noreply, socket}
  end
end
