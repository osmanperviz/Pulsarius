defmodule PulsariusWeb.IntegrationLiveTest do
  use PulsariusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pulsarius.IntegrationsFixtures

  @create_attrs %{
    channel_name: "some channel_name",
    name: "some name",
    type: "some type",
    webhook_url: "some webhook_url"
  }
  @update_attrs %{
    channel_name: "some updated channel_name",
    name: "some updated name",
    type: "some updated type",
    webhook_url: "some updated webhook_url"
  }
  @invalid_attrs %{channel_name: nil, name: nil, type: nil, webhook_url: nil}

  defp create_integration(_) do
    integration = integration_fixture()
    %{integration: integration}
  end

  describe "Index" do
    setup [:create_integration]

    test "lists all integrations", %{conn: conn, integration: integration} do
      {:ok, _index_live, html} = live(conn, Routes.integration_index_path(conn, :index))

      assert html =~ "Listing Integrations"
      assert html =~ integration.channel_name
    end

    test "saves new integration", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.integration_index_path(conn, :index))

      assert index_live |> element("a", "New Integration") |> render_click() =~
               "New Integration"

      assert_patch(index_live, Routes.integration_index_path(conn, :new))

      assert index_live
             |> form("#integration-form", integration: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#integration-form", integration: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.integration_index_path(conn, :index))

      assert html =~ "Integration created successfully"
      assert html =~ "some channel_name"
    end

    test "updates integration in listing", %{conn: conn, integration: integration} do
      {:ok, index_live, _html} = live(conn, Routes.integration_index_path(conn, :index))

      assert index_live |> element("#integration-#{integration.id} a", "Edit") |> render_click() =~
               "Edit Integration"

      assert_patch(index_live, Routes.integration_index_path(conn, :edit, integration))

      assert index_live
             |> form("#integration-form", integration: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#integration-form", integration: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.integration_index_path(conn, :index))

      assert html =~ "Integration updated successfully"
      assert html =~ "some updated channel_name"
    end

    test "deletes integration in listing", %{conn: conn, integration: integration} do
      {:ok, index_live, _html} = live(conn, Routes.integration_index_path(conn, :index))

      assert index_live |> element("#integration-#{integration.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#integration-#{integration.id}")
    end
  end

  describe "Show" do
    setup [:create_integration]

    test "displays integration", %{conn: conn, integration: integration} do
      {:ok, _show_live, html} = live(conn, Routes.integration_show_path(conn, :show, integration))

      assert html =~ "Show Integration"
      assert html =~ integration.channel_name
    end

    test "updates integration within modal", %{conn: conn, integration: integration} do
      {:ok, show_live, _html} = live(conn, Routes.integration_show_path(conn, :show, integration))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Integration"

      assert_patch(show_live, Routes.integration_show_path(conn, :edit, integration))

      assert show_live
             |> form("#integration-form", integration: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#integration-form", integration: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.integration_show_path(conn, :show, integration))

      assert html =~ "Integration updated successfully"
      assert html =~ "some updated channel_name"
    end
  end
end
