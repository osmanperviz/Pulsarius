defmodule Pulsarius.MonitoringTest do
  use Pulsarius.DataCase

  alias Pulsarius.Monitoring
  import Pulsarius.AccountsFixtures
  import Pulsarius.MonitoringFixtures

  defp setup_monitor(_conn) do
    account = account_fixture()
    monitor_params = %{}

    monitor = monitor_fixture(account, monitor_params)

    %{monitor: monitor}
  end

  describe "monitoring" do
    setup [:setup_monitor]
    alias Pulsarius.Monitoring.Monitor

    test "list_monitoring/0 returns all monitoring", %{monitor: monitor} do
      assert Monitoring.list_monitoring() == [monitor]
    end

    test "get_monitor!/1 returns the monitor with given id", %{monitor: monitor} do
      assert Monitoring.get_monitor!(monitor.id) == monitor
    end

    test "create_monitor/1 with valid data creates a monitor" do
      valid_attrs = %{name: "some monitor", status: :active}

      assert {:ok, %Monitor{} = monitor} = Monitoring.create_monitor(valid_attrs)
    end

    test "create_monitor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Monitoring.create_monitor(%{})
    end

    test "update_monitor/2 with valid data updates the monitor", %{monitor: monitor} do
      update_attrs = %{name: "new name"}

      assert {:ok, %Monitor{} = monitor} = Monitoring.update_monitor(monitor, update_attrs)

      assert monitor.name == "new name"
    end

    test "update_monitor/2 with invalid data returns error changeset", %{monitor: monitor} do
      assert {:error, %Ecto.Changeset{}} = Monitoring.update_monitor(monitor, %{name: ""})

      assert monitor == Monitoring.get_monitor!(monitor.id)
    end

    test "delete_monitor/1 deletes the monitor", %{monitor: monitor} do
      assert {:ok, %Monitor{}} = Monitoring.delete_monitor(monitor)
      assert_raise Ecto.NoResultsError, fn -> Monitoring.get_monitor!(monitor.id) end
    end

    test "change_monitor/1 returns a monitor changeset", %{onitor: monitor} do
      assert %Ecto.Changeset{} = Monitoring.change_monitor(monitor)
    end
  end
end
