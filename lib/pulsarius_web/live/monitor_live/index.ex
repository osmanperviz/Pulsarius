defmodule PulsariusWeb.MonitorLive.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring
  alias PulsariusWeb.MonitorLive.MonitorWidget
  alias PulsariusWeb.MonitorLive.ConfigurationProgressComponent
  alias Pulsarius.Accounts

  alias Pulsarius.Monitoring.Monitor

  alias Pulsarius.Repo

  import PulsariusWeb.MonitorLive.MonitoringComponents

  @topic "monitor"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, fetch_default_assigns(socket)}
  end

  @impl true
  def handle_event(
        "search-monitor",
        %{"monitor_search" => %{"query" => query}},
        %{assigns: assigns} = socket
      )
      when query != "" do
    monitoring_list = Enum.filter(assigns.monitoring, &String.contains?(&1.name, query))

    {:noreply, assign(socket, :monitoring, monitoring_list)}
  end

  def handle_event("search-monitor", _params, %{assigns: assigns} = socket) do
    monitoring_list = Monitoring.list_monitoring_with_daily_statistics(assigns.account.id)

    {:noreply, assign(socket, :monitoring, monitoring_list)}
  end

  @impl true
  def handle_event("dismiss-onboarding-progress-wizard", _params, %{assigns: assigns} = socket) do
    {:ok, user} =
      Accounts.update_user(assigns.current_user, %{
        show_onboard_progress_wizard: false
      })

    socket =
      socket
      |> assign(:current_user, user)
      |> fetch_default_assigns()

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete-monitor", %{"id" => id}, socket) do
    {:ok, monitor} =
      Monitoring.get_monitor!(id)
      |> Monitoring.delete_monitor()

    # stop related running monitor process
    Pulsarius.EndpointChecker.stop_monitoring(monitor)

    {:noreply, fetch_default_assigns(socket)}
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
      invite_colleagues: Accounts.has_team_member?(account),
      integrations: has_integrations_set?(monitor),
      notifications: false,
      status_page: false
    }
  end

  def onboarding_progress(_no_monitor, account) do
    %{
      create_monitoring: false,
      invite_colleagues: Accounts.has_team_member?(account),
      integrations: false,
      notifications: false,
      status_page: false
    }
  end

  def fetch_default_assigns(%{assigns: assigns} = socket) do
    monitoring_list = Monitoring.list_monitoring_with_daily_statistics(assigns.account.id)

    if assigns.current_user.show_onboard_progress_wizard do
      onboarding_progress = onboarding_progress(monitoring_list, assigns.account)

      socket
      |> assign(:monitoring, monitoring_list)
      |> assign(:onboarding_progress, onboarding_progress)
    else
      socket
      |> assign(:monitoring, monitoring_list)
      |> assign(:onboarding_progress, false)
    end
  end

  defp has_integrations_set?(monitor) do
    monitor.configuration.slack_notification
  end
end
