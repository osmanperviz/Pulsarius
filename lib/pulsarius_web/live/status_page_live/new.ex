defmodule PulsariusWeb.StatusPageLive.New do
  use PulsariusWeb, :live_view

  alias Pulsarius.StatusPages
  alias Pulsarius.StatusPages.StatusPage
  alias Pulsarius.Monitoring

  @impl true
  def mount(_params, _session, %{assigns: assigns} = socket) do
    monitors = Monitoring.list_monitoring_for_account(assigns.account.id)

    socket =
      socket
      |> assign(:status_page, %StatusPage{monitors: []})
      |> assign(:account_id, assigns.account.id)
      |> assign(:monitors, monitors)

    {:ok, socket}
  end
end
