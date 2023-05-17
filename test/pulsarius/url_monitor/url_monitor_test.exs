defmodule Pulsarius.UrlMonitorTest do
  use Pulsarius.DataCase

  alias Pulsarius.UrlMonitor
  alias Pulsarius.Monitoring.StatusResponse

  import Pulsarius.ConfigurationsFixtures
  import Pulsarius.MonitoringFixtures
  import Pulsarius.AccountsFixtures
  import Pulsarius.IncidentsFixtures

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  defp setup_monitor(_conn) do
    account = account_fixture()
    monitor_params = %{configuration: build_configuration_fixture()}

    monitor = monitor_fixture(account, monitor_params)

    %{monitor: monitor}
  end

  describe "public functions" do
    setup [:setup_monitor]

    test "start_link/1 starts a new UrlMonitor process with a unique name", %{monitor: monitor} do
      assert {:ok, _pid} = UrlMonitor.start_link(monitor)
      assert {:error, {:already_started, _pid}} = UrlMonitor.start_link(monitor)
    end

    test "stop_monitoring/1 stops the UrlMonitor process", %{monitor: monitor} do
      {:ok, pid} = UrlMonitor.start_link(monitor)

      assert Process.alive?(pid)
      assert :ok = UrlMonitor.stop_monitoring(monitor)
      refute Process.alive?(pid)
    end

    test "update_state/1 it update state and return :ok", %{monitor: monitor} do
      state = %{monitor: monitor}

      {:ok, pid} = UrlMonitor.start_link(monitor)

      new_monitor = %Pulsarius.Monitoring.Monitor{
        monitor
        | name: "some-new-name",
          active_incident: nil
      }

      :ok = UrlMonitor.update_state(new_monitor)

      process_state = :sys.get_state(pid)

      assert process_state.monitor.name == "some-new-name"
    end
  end

  describe "handle_available/1" do
    setup [:setup_monitor]

    test "when service is available and bot is not in incident mode, status response is saved to the database",
         %{monitor: monitor} do
      state = %{
        start_measuring_response_time: nil,
        strategy: %{alert_rule: :becomes_unavailable, alert_condition: nil},
        in_incident_mode: false,
        incident: nil,
        monitor: monitor
      }

      Pulsarius.UrlMonitor.MockUrlMonitorApi
      |> expect(:send_request, fn url ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "my ass"}}
      end)

      assert {:noreply, new_state} = UrlMonitor.handle_info(:check, state)

      assert new_state.in_incident_mode == false
      assert new_state.incident == nil
      assert new_state.start_measuring_response_time == nil

      assert Pulsarius.Repo.get_by(StatusResponse, monitor_id: monitor.id)
    end

    test "Updates number_of_success_retry when service is available and bot is in incident mode",
         %{monitor: monitor} do
      state = %{
        start_measuring_response_time: nil,
        strategy: %{alert_rule: :becomes_unavailable, alert_condition: nil},
        in_incident_mode: true,
        number_of_success_retry: 1,
        incident: incident_fixture(monitor, %{resolved_at: nil}),
        retries: 0,
        retry_limit: 3,
        monitor: monitor
      }

      Pulsarius.UrlMonitor.MockUrlMonitorApi
      |> expect(:send_request, fn url ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
      end)

      assert {:noreply, new_state} = UrlMonitor.handle_info(:check, state)
      assert new_state.in_incident_mode == true
      assert new_state.number_of_success_retry == 2
    end

    test "Auto-resolves incident and resets retry count after successful service check in incident mode",
         %{monitor: monitor} do
      state = %{
        start_measuring_response_time: nil,
        strategy: %{alert_rule: :becomes_unavailable, alert_condition: nil},
        in_incident_mode: true,
        number_of_success_retry: 3,
        incident: incident_fixture(monitor, %{resolved_at: nil}),
        retries: 0,
        retry_limit: 3,
        monitor: %{monitor | status: :inactive}
      }

      Pulsarius.subscribe("incidents")

      Pulsarius.UrlMonitor.MockUrlMonitorApi
      |> expect(:send_request, fn url ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "ok"}}
      end)

      assert {:noreply, new_state} = UrlMonitor.handle_info(:check, state)
      assert new_state.in_incident_mode == false
      assert new_state.incident == nil
      assert new_state.number_of_success_retry == 0

      assert_receive {:incident_auto_resolved, _payload}
    end
  end

  describe "handle_unavailable/1" do
    setup [:setup_monitor]

    test "When service is unavailable and bot is in incident mode, it should remain in incident mode and schedule next check",
         %{monitor: monitor} do
      state = %{
        start_measuring_response_time: nil,
        strategy: %{alert_rule: :becomes_unavailable, alert_condition: nil},
        in_incident_mode: true,
        number_of_success_retry: 0,
        incident: incident_fixture(monitor, %{resolved_at: nil}),
        retries: 0,
        retry_limit: 3,
        monitor: %{monitor | status: :inactive}
      }

      Pulsarius.UrlMonitor.MockUrlMonitorApi
      |> expect(:send_request, fn url ->
        {:ok, %HTTPoison.Response{status_code: 500, body: "internal server error"}}
      end)

      assert {:noreply, new_state} = UrlMonitor.handle_info(:check, state)

      assert new_state.in_incident_mode == true
    end

    test "When monitoring an unavailable service, the bot should retry up to the maximum retry limit before going into incident mode if it was not previously in incident mode",
         %{monitor: monitor} do
      state = %{
        start_measuring_response_time: nil,
        strategy: %{alert_rule: :becomes_unavailable, alert_condition: nil},
        in_incident_mode: false,
        number_of_success_retry: 0,
        incident: nil,
        retries: 0,
        retry_limit: 3,
        monitor: %{monitor | status: :active}
      }

      Pulsarius.UrlMonitor.MockUrlMonitorApi
      |> expect(:send_request, fn url ->
        {:ok, %HTTPoison.Response{status_code: 500, body: "internal server error"}}
      end)

      assert {:noreply, new_state} = UrlMonitor.handle_info(:check, state)

      assert new_state.in_incident_mode == false

      assert new_state.retries == 1

      assert new_state.monitor.status == :active
    end

    test "When the service becomes unavailable and the retry limit is reached, the bot should enter incident mode and the monitor should become inactive",
         %{monitor: monitor} do
      state = %{
        start_measuring_response_time: nil,
        strategy: %{alert_rule: :becomes_unavailable, alert_condition: nil},
        in_incident_mode: false,
        number_of_success_retry: 0,
        incident: nil,
        retries: 3,
        retry_limit: 3,
        monitor: %{monitor | status: :active}
      }

      Pulsarius.UrlMonitor.MockUrlMonitorApi
      |> expect(:send_request, fn url ->
        {:ok, %HTTPoison.Response{status_code: 500, body: "internal server error"}}
      end)

      Pulsarius.subscribe("incidents")

      assert {:noreply, new_state} = UrlMonitor.handle_info(:check, state)

      assert new_state.in_incident_mode == true

      refute new_state.incident == nil

      assert new_state.monitor.status == :inactive

      assert_receive {:incident_created, _payload}
    end
  end
end
