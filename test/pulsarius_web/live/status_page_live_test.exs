defmodule PulsariusWeb.StatusPageLiveTest do
  use PulsariusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pulsarius.StatusPagesFixtures

  @create_attrs %{
    name: "some name",
    description: "some description",
    url: "some url",
    is_public: true
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    url: "some updated url",
    is_public: false
  }
  @invalid_attrs %{name: nil, description: nil, url: nil, is_public: false}

  defp create_status_page(_) do
    status_page = status_page_fixture()
    %{status_page: status_page}
  end

  describe "Index" do
    setup [:create_status_page]

    test "lists all status_pages", %{conn: conn, status_page: status_page} do
      {:ok, _index_live, html} = live(conn, Routes.status_page_index_path(conn, :index))

      assert html =~ "Listing Status pages"
      assert html =~ status_page.name
    end

    test "saves new status_page", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.status_page_index_path(conn, :index))

      assert index_live |> element("a", "New Status page") |> render_click() =~
               "New Status page"

      assert_patch(index_live, Routes.status_page_index_path(conn, :new))

      assert index_live
             |> form("#status_page-form", status_page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#status_page-form", status_page: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.status_page_index_path(conn, :index))

      assert html =~ "Status page created successfully"
      assert html =~ "some name"
    end

    test "updates status_page in listing", %{conn: conn, status_page: status_page} do
      {:ok, index_live, _html} = live(conn, Routes.status_page_index_path(conn, :index))

      assert index_live |> element("#status_page-#{status_page.id} a", "Edit") |> render_click() =~
               "Edit Status page"

      assert_patch(index_live, Routes.status_page_index_path(conn, :edit, status_page))

      assert index_live
             |> form("#status_page-form", status_page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#status_page-form", status_page: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.status_page_index_path(conn, :index))

      assert html =~ "Status page updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes status_page in listing", %{conn: conn, status_page: status_page} do
      {:ok, index_live, _html} = live(conn, Routes.status_page_index_path(conn, :index))

      assert index_live |> element("#status_page-#{status_page.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#status_page-#{status_page.id}")
    end
  end

  describe "Show" do
    setup [:create_status_page]

    test "displays status_page", %{conn: conn, status_page: status_page} do
      {:ok, _show_live, html} = live(conn, Routes.status_page_show_path(conn, :show, status_page))

      assert html =~ "Show Status page"
      assert html =~ status_page.name
    end

    test "updates status_page within modal", %{conn: conn, status_page: status_page} do
      {:ok, show_live, _html} = live(conn, Routes.status_page_show_path(conn, :show, status_page))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Status page"

      assert_patch(show_live, Routes.status_page_show_path(conn, :edit, status_page))

      assert show_live
             |> form("#status_page-form", status_page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#status_page-form", status_page: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.status_page_show_path(conn, :show, status_page))

      assert html =~ "Status page updated successfully"
      assert html =~ "some updated name"
    end
  end
end
