defmodule Pulsarius.Notifications.NotificationServer do
  use GenServer

  alias Pulsarius.Notifications

  def start_link(monitor) do
    GenServer.start_link(__MODULE__, %{}, name: :notification_server)
  end

  def init(state) do
    topics_to_subscribe = ["incidents", "invitations"]

    topics_to_subscribe
    |> Enum.map(&Pulsarius.subscribe/1)

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

  def handle_info({:user_invitation_created, invitation}, socket) do
    Notifications.user_invitation_created(invitation)

    {:noreply, socket}
  end
end
