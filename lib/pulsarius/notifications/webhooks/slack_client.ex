defmodule Pulsarius.Notifications.Webhooks.SlackClient do
  def send(webhook_url, body) do
    HTTPoison.post(
      webhook_url,
      body,
      [{"Content-Type", "application/json"}]
    )
  end
end
