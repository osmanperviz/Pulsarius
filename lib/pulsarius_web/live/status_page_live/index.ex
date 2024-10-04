defmodule PulsariusWeb.StatusPageLive.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.StatusPages
  alias Pulsarius.StatusPages.StatusPage

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :status_pages, list_status_pages())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Status page")
    |> assign(:status_page, StatusPages.get_status_page!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Status page")
    |> assign(:status_page, %StatusPage{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Status pages")
    |> assign(:status_page, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    status_page = StatusPages.get_status_page!(id)
    {:ok, _} = StatusPages.delete_status_page(status_page)

    {:noreply, assign(socket, :status_pages, list_status_pages())}
  end

  defp list_status_pages do
    StatusPages.list_status_pages()
  end
end
