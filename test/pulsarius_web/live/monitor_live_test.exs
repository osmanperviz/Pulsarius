defmodule PulsariusWeb.MonitorLiveTest do
  use PulsariusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pulsarius.MonitoringFixtures
  import Pulsarius.AccountsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_monitor(_) do
    account = account_fixture()
    monitor = monitor_fixture(account)
    %{monitor: monitor}
  end

  describe "Index" do
    setup [:create_monitor]

    test "lists all monitoring", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.monitor_index_path(conn, :index))

      assert html =~ "Listing Monitoring"
    end

    test "saves new monitor", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.monitor_index_path(conn, :index))

      assert index_live |> element("a", "New Monitor") |> render_click() =~
               "New Monitor"

      assert_patch(index_live, Routes.monitor_index_path(conn, :new))

      assert index_live
             |> form("#monitor-form", monitor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#monitor-form", monitor: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.monitor_index_path(conn, :index))

      assert html =~ "Monitor created successfully"
    end

    test "updates monitor in listing", %{conn: conn, monitor: monitor} do
      {:ok, index_live, _html} = live(conn, Routes.monitor_index_path(conn, :index))

      assert index_live |> element("#monitor-#{monitor.id} a", "Edit") |> render_click() =~
               "Edit Monitor"

      assert_patch(index_live, Routes.monitor_index_path(conn, :edit, monitor))

      assert index_live
             |> form("#monitor-form", monitor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#monitor-form", monitor: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.monitor_index_path(conn, :index))

      assert html =~ "Monitor updated successfully"
    end

    test "deletes monitor in listing", %{conn: conn, monitor: monitor} do
      {:ok, index_live, _html} = live(conn, Routes.monitor_index_path(conn, :index))

      assert index_live |> element("#monitor-#{monitor.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#monitor-#{monitor.id}")
    end
  end

  describe "Show" do
    setup [:create_monitor]

    test "displays monitor", %{conn: conn, monitor: monitor} do
      {:ok, _show_live, html} = live(conn, Routes.monitor_show_path(conn, :show, monitor))

      assert html =~ "Show Monitor"
    end

    test "updates monitor within modal", %{conn: conn, monitor: monitor} do
      {:ok, show_live, _html} = live(conn, Routes.monitor_show_path(conn, :show, monitor))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Monitor"

      assert_patch(show_live, Routes.monitor_show_path(conn, :edit, monitor))

      assert show_live
             |> form("#monitor-form", monitor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#monitor-form", monitor: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.monitor_show_path(conn, :show, monitor))

      assert html =~ "Monitor updated successfully"
    end
  end
end
