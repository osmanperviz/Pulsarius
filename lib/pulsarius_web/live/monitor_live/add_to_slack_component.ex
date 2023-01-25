defmodule PulsariusWeb.MonitorLive.AddSlackIntegrationComponent do
  use PulsariusWeb, :component

  def add_slack_integration(assigns) do
    ~H"""
    <%= if @monitor.configuration.slack_notification == false do %>
      <%= link("Integrate with Slack",
        to: link_to_slack(@monitor.id),
        class: "btn btn-sm btn-outline-warning mt-3"
      ) %>
    <% else %>
      <%= link("Remove Slack Integration",
        to: "#",
        class: "btn btn-sm btn-outline-danger mt-3"
      ) %>
    <% end %>
    """
  end

  defp link_to_slack(monitor_id) do
    client_id = Application.get_env(:pulsarius, :slack_integration)[:client_id]
    # it's not working locally!
    redirect_url = "localhost:4000/monitor/#{monitor_id}/integrations/slack"

    "https://slack.com/oauth/v2/authorize?client_id=#{client_id}&redirect_uri=#{redirect_url}&scope=users:read,users:read.email,incoming-webhook&user_scope="
  end
end
