defmodule PulsariusWeb.StatusPageLive.Edit do
  use PulsariusWeb, :live_view

  alias Pulsarius.StatusPages
  alias Pulsarius.StatusPages.StatusPage

  @impl true
  def mount(%{"id" => id} = params, _session, socket) do
    status_page = StatusPages.get_status_page!(id)
    {:ok, assign(socket, :status_page, status_page)}
  end
end
