defmodule Pulsarius.Notifications.NotificationServer do
    use GenServer

  alias Pulsarius.Notifications


  def start_link(monitor) do
    GenServer.start_link(__MODULE__, %{}, name: :notivication_server)
  end

  def init(state) do
    Pulsarius.subscribe("INCIDENT_CREATED")

    {:ok, state}
  end

  def handle_info({:incident_created, incident}, socket) do
    Notifications.incident_created(incident, %{})

    {:noreply, socket}
  end
end