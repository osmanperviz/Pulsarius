defmodule PulsariusWeb.EmailsView do
  use Phoenix.View,
    root: "lib/pulsarius_web/notifications"

  use Phoenix.Component

  alias PulsariusWeb.Router.Helpers, as: Routes

  def user_invitation_url(token) do
    Routes.user_invitation_url(PulsariusWeb.Endpoint, :accept, token)
  end
end
