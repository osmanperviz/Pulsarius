defmodule PulsariusWeb.MonitorLive.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring
  alias PulsariusWeb.MonitorLive.MonitorWidget
  alias PulsariusWeb.MonitorLive.ConfigurationProgressComponent

  alias Pulsarius.Monitoring.Monitor

  alias Pulsarius.Repo

  import PulsariusWeb.MonitorLive.MonitoringComponents

  @topic "monitor"

  @impl true
  def mount(_params, _session, %{assigns: assigns} = socket) do
    monitoring_list = Monitoring.list_monitoring_with_daily_statistics(assigns.account.id)
    onboarding_progress = onboarding_progress(monitoring_list, assigns.account)

    socket =
      socket
      |> assign(:monitoring, monitoring_list)
      |> assign(:onboarding_progress, onboarding_progress)

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    monitor = Monitoring.get_monitor!(id)
    {:ok, _} = Monitoring.delete_monitor(monitor)

    # stop related running monitor process
    Pulsarius.EndpointChecker.stop_monitoring(monitor)

    {:noreply, assign(socket, :monitoring, Monitoring.list_monitoring())}
  end

  @impl true
  def handle_event(
        "pause-monitoring",
        %{"monitor_id" => monitor_id},
        %{assigns: assigns} = socket
      ) do
    monitor = Enum.find(assigns.monitoring, &(&1.id == monitor_id))
    {:ok, monitor} = Monitoring.update_monitor(monitor, %{status: "paused"})

    monitor = Pulsarius.Repo.preload(monitor, [:configuration])
    :ok = Pulsarius.EndpointChecker.update_state(monitor)
    Pulsarius.broadcast(@topic, {:monitor_paused, monitor})

    monitoring = replace_monitoring(assigns.monitoring, monitor.id, monitor)

    {:noreply, assign(socket, :monitoring, monitoring)}
  end

  @impl true
  def handle_event(
        "unpause-monitoring",
        %{"monitor_id" => monitor_id},
        %{assigns: assigns} = socket
      ) do
    monitor = Enum.find(assigns.monitoring, &(&1.id == monitor_id))
    {:ok, monitor} = Monitoring.update_monitor(monitor, %{status: "active"})

    monitor = Pulsarius.Repo.preload(monitor, [:configuration])

    :ok = Pulsarius.EndpointChecker.update_state(monitor)
    Pulsarius.broadcast(@topic, {:monitor_unpaused, monitor})

    monitoring = replace_monitoring(assigns.monitoring, monitor.id, monitor)

    {:noreply, assign(socket, :monitoring, monitoring)}
  end

  def handle_event("send-test-alert", _params, %{assigns: assigns} = socket) do
    Pulsarius.broadcast("monitor", {:send_test_alert, assigns.current_user})

    socket =
      put_flash(
        socket,
        :info,
        "We sent you a test alert. Don't worry, your colleagues were not notified."
      )

    {:noreply, socket}
  end

  def handle_event(
        "delete-monitoring",
        %{"monitor_id" => monitor_id},
        %{assigns: assigns} = socket
      ) do
    monitoring_list = Monitoring.list_monitoring_with_daily_statistics(assigns.account.id)

    {:noreply, assign(socket, :monitoring, monitoring_list)}
  end

  def replace_monitoring(list, id, to) do
    list
    |> Enum.map(fn
      %Monitor{id: ^id} -> to
      other -> other
    end)
  end

  def onboarding_progress([monitor | _rest], account) do
    %{
      create_monitoring: true,
      invite_colleagues: has_team_member?(account),
      integrations: has_integrations_set?(monitor),
      notifications: false,
      status_page: false
    }
  end

  defp has_team_member?(account) do
    account = account |> Repo.preload(:users)
    Enum.count(account.users) > 1
  end

  defp has_integrations_set?(monitor) do
    monitor.configuration.slack_notification
  end
end
