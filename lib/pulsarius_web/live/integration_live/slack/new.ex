defmodule PulsariusWeb.IntegrationsLive.Slack.New do
  use PulsariusWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
