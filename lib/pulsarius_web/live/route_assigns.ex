defmodule PulsariusWeb.RouteAssigns do
  use PulsariusWeb, :live_view

  alias PulsariusWeb.Router.Helpers, as: Routes

  def on_mount(:default, _params, _session, socket) do
    socket =
      assign(socket,
        menus: [
          {"Monitor", Routes.monitor_index_path(socket, :index), "bi bi-display fs-6"},
          {"Incidents", Routes.incidents_account_path(socket, :index, socket.assigns.account.id),
           "bi bi-shield-exclamation fs-6"},
          {"Team", Routes.user_index_path(socket, :index), "bi bi-people fs-6"},
          {"Integrations", Routes.integrations_index_path(socket, :index), "bi bi-globe fs-6"},
          {"Status Page", Routes.status_page_index_path(socket, :index),
           "bi bi-file-earmark-play fs-6"},
          {"Pricing", Routes.subscription_pricing_path(socket, :pricing), "bi bi-bag fs-6"}
        ]
      )

    {:cont,
     socket
     |> attach_hook(:set_menu_path, :handle_params, &manage_active_tabs/3)}
  end

  defp manage_active_tabs(_params, url, socket) do
    {:cont, assign(socket, current_path: URI.parse(url).path)}
  end
end
