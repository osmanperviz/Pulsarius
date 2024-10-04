defmodule Pulsarius.StatusPagesTest do
  use Pulsarius.DataCase

  alias Pulsarius.StatusPages

  describe "status_pages" do
    alias Pulsarius.StatusPages.StatusPage

    import Pulsarius.StatusPagesFixtures

    @invalid_attrs %{name: nil, description: nil, url: nil, is_public: nil}

    test "list_status_pages/0 returns all status_pages" do
      status_page = status_page_fixture()
      assert StatusPages.list_status_pages() == [status_page]
    end

    test "get_status_page!/1 returns the status_page with given id" do
      status_page = status_page_fixture()
      assert StatusPages.get_status_page!(status_page.id) == status_page
    end

    test "create_status_page/1 with valid data creates a status_page" do
      valid_attrs = %{name: "some name", description: "some description", url: "some url", is_public: true}

      assert {:ok, %StatusPage{} = status_page} = StatusPages.create_status_page(valid_attrs)
      assert status_page.name == "some name"
      assert status_page.description == "some description"
      assert status_page.url == "some url"
      assert status_page.is_public == true
    end

    test "create_status_page/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StatusPages.create_status_page(@invalid_attrs)
    end

    test "update_status_page/2 with valid data updates the status_page" do
      status_page = status_page_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", url: "some updated url", is_public: false}

      assert {:ok, %StatusPage{} = status_page} = StatusPages.update_status_page(status_page, update_attrs)
      assert status_page.name == "some updated name"
      assert status_page.description == "some updated description"
      assert status_page.url == "some updated url"
      assert status_page.is_public == false
    end

    test "update_status_page/2 with invalid data returns error changeset" do
      status_page = status_page_fixture()
      assert {:error, %Ecto.Changeset{}} = StatusPages.update_status_page(status_page, @invalid_attrs)
      assert status_page == StatusPages.get_status_page!(status_page.id)
    end

    test "delete_status_page/1 deletes the status_page" do
      status_page = status_page_fixture()
      assert {:ok, %StatusPage{}} = StatusPages.delete_status_page(status_page)
      assert_raise Ecto.NoResultsError, fn -> StatusPages.get_status_page!(status_page.id) end
    end

    test "change_status_page/1 returns a status_page changeset" do
      status_page = status_page_fixture()
      assert %Ecto.Changeset{} = StatusPages.change_status_page(status_page)
    end
  end
end
