defmodule PulsariusWeb.EmailsView do
  use Phoenix.View,
    root: "lib/pulsarius_web/notifications"

  use Phoenix.Component

  alias PulsariusWeb.Router.Helpers, as: Routes

  def user_invitation_url(token) do
    Routes.user_invitation_url(PulsariusWeb.Endpoint, :accept, token)
  end

  def incident_detail_url(incident) do
    Routes.incidents_show_url(
      PulsariusWeb.Endpoint,
      :show,
      incident.monitor_id,
      incident.id
    )
  end

  def login_link(token) do
    Routes.user_session_path(PulsariusWeb.Endpoint, :log_in, token: token
    )
  end

  def calculate_length(incident) do
    PulsariusWeb.LiveHelpers.humanized_duration(incident.occured_at, incident.resolved_at)
  end
end
