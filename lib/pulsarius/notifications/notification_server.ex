defmodule Pulsarius.Notifications.NotificationServer do
  use GenServer

  alias Pulsarius.Notifications

  def start_link(monitor) do
    GenServer.start_link(__MODULE__, %{}, name: :notification_server)
  end

  def init(state) do
    topics_to_subscribe = ["incidents", "invitations", "monitor", "deliver_magic_link", "deliver_welcome_email"]

    topics_to_subscribe
    |> Enum.map(&Pulsarius.subscribe/1)

    {:ok, state}
  end

  def handle_info({:incident_created, incident}, socket) do
    Task.start(fn -> Notifications.incident_created(incident) end)

    {:noreply, socket}
  end

  # TODO: write implementation
  def handle_info({:incident_acknowledged, incident}, socket) do
    Task.start(fn -> Notifications.incident_acknowledged(incident) end)
    {:noreply, socket}
  end

  def handle_info({:incident_auto_resolved, incident}, socket) do
    Task.start(fn -> Notifications.incident_auto_resolved(incident) end)

    {:noreply, socket}
  end

  def handle_info({:incident_resolved, args}, socket) do
    Task.start(fn -> Notifications.incident_resolved(args) end)

    {:noreply, socket}
  end

  def handle_info({:monitor_paused, args}, socket) do
    Task.start(fn -> Notifications.monitor_paused(args) end)

    {:noreply, socket}
  end

  def handle_info({:monitor_unpaused, args}, socket) do
    Task.start(fn -> Notifications.monitor_unpaused(args) end)

    {:noreply, socket}
  end

  def handle_info({:send_test_alert, args}, socket) do
    Task.start(fn -> Notifications.send_test_alert(args) end)

    {:noreply, socket}
  end

  def handle_info({:user_invitation_created, invitation}, socket) do
    Task.start(fn -> Notifications.user_invitation_created(invitation) end)

    {:noreply, socket}
  end

  def handle_info({:send_magic_link, args}, socket) do
    Task.start(fn -> Notifications.send_magic_link(args) end)

    {:noreply, socket}
  end

  def handle_info({:send_welcome_email, args}, socket) do
    Task.start(fn -> Notifications.send_welcome_email(args) end)

    {:noreply, socket}
  end
end
