defmodule PulsariusWeb.StatusPageLive.Show do
  use PulsariusWeb, :live_view

  alias Pulsarius.StatusPages

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:status_page, StatusPages.get_status_page!(id))}
  end

  defp page_title(:show), do: "Show Status page"
  defp page_title(:edit), do: "Edit Status page"
end
