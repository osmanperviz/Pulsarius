defmodule PulsariusWeb.StatusPageLive.Edit do
  use PulsariusWeb, :live_view

  alias Pulsarius.StatusPages
  alias Pulsarius.StatusPages.StatusPage
  alias Pulsarius.Monitoring

  @impl true
  def mount(%{"id" => id} = params, _session, socket) do
    monitors = Monitoring.list_monitoring_for_account(socket.assigns.account.id)

    status_page =
      StatusPages.get_status_page!(id)
      |> Pulsarius.Repo.preload(:monitors)

    {:ok,
     socket
     |> assign(:status_page, status_page)
     |> assign(:monitors, monitors)}
  end
end
