defmodule PulsariusWeb.MonitorLive.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring
  alias PulsariusWeb.MonitorLive.MonitorWidget
  alias PulsariusWeb.MonitorLive.ConfigurationProgressComponent
  alias Pulsarius.Monitoring.{AvalabilityStatistics, StatusResponse}
  alias Pulsarius.Accounts
  alias Pulsarius.Monitoring.Monitor
  alias Pulsarius.Repo

  import PulsariusWeb.MonitorLive.MonitoringComponents

  use Timex

  @topic "monitor"

  @impl true
  def mount(_params, _session, socket) do
    socket = fetch_default_assigns(socket)
    subscribe_to_monitor_events(socket.assigns.monitoring)

    {:ok, socket}
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
    Pulsarius.UrlMonitor.stop_monitoring(monitor)

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
    :ok = Pulsarius.UrlMonitor.update_state(monitor)
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

    status =
      if monitor.active_incident == nil,
        do: "active",
        else: "inactive"

    {:ok, monitor} = Monitoring.update_monitor(monitor, %{status: status})

    monitor = Pulsarius.Repo.preload(monitor, [:configuration])

    :ok = Pulsarius.UrlMonitor.update_state(monitor)
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

  def handle_info(%Monitor{} = monitor, %{assigns: assigns} = socket) do
    monitor =
      Pulsarius.Repo.preload(monitor, [
        :configuration,
        :active_incident,
        :incidents,
        :status_response
      ])

    statistics =
      Map.merge(AvalabilityStatistics.calculate_todays_stats(monitor.incidents), %{
        average_response_time:
          AvalabilityStatistics.calculate_average_response_time(monitor.status_response)
      })

    monitor = Monitor.cast_statistics(monitor, statistics)

    monitoring_list = Enum.filter(assigns.monitoring, &(&1.id != monitor.id)) ++ [monitor]

    {:noreply, assign(socket, :monitoring, monitoring_list)}
  end

  def handle_info(%StatusResponse{} = status_response, %{assigns: assigns} = socket) do
    monitor = assigns.monitoring |> Enum.find(&(&1.id == status_response.monitoring.id))

    {:noreply,
     socket
     |> push_event("response_time:#{monitor.id}", %{
       response_time: build_response_time(monitor.status_response ++ [status_response])
     })}
  end

  # monitor:f744567e-dfbb-487b-acb8-3fb90a401ce2
  #  monitor = Pulsarius.Repo.get!(Pulsarius.Monitoring.Monitor, "f744567e-dfbb-487b-acb8-3fb90a401ce2")
  #  Pulsarius.broadcast("monitor:" <> monitor.id, monitor)

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
      integrations: Accounts.has_any_integration_set?(account),
      notifications: false,
      status_page: false
    }
  end

  def onboarding_progress(_no_monitor, account) do
    %{
      create_monitoring: false,
      invite_colleagues: Accounts.has_team_member?(account),
      integrations: Accounts.has_any_integration_set?(account),
      notifications: false,
      status_page: false
    }
  end

  defp fetch_default_assigns(%{assigns: assigns} = socket) do
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

  defp subscribe_to_monitor_events(monitors) do
    monitors
    |> Enum.map(&Pulsarius.subscribe("monitor:" <> &1.id))
  end

  def build_response_time(response_time) do
    Enum.filter(response_time, fn rt ->
      rt.occured_at in todays_range()
    end)
    |> Enum.sort_by(&Map.fetch!(&1, :inserted_at), :desc)
    |> Enum.take(80)
    |> Enum.reverse()
    |> Enum.map(fn a ->
      %{x: NaiveDateTime.to_time(a.occured_at) |> Time.to_string(), y: a.response_time_in_ms}
    end)
  end

  defp todays_range() do
    from = Timex.now() |> Timex.beginning_of_day()
    until = Timex.now() |> Timex.end_of_day()

    Interval.new(from: from, until: until)
  end
end
