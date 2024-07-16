defmodule Pulsarius.Notifications.Webhooks do
  alias Pulsarius.Notifications.Webhooks.Slack
  alias Pulsarius.Notifications.Webhooks.MsTeams

  def deliver(%{webhook_url: webhook_url, body: body}) do
    HTTPoison.post(
      webhook_url,
      body,
      [{"Content-type", "application/json"}]
    )
  end

  def notifications_for(type, params) do
    slack_notifications = apply(Slack, type, [params])
    ms_tems_notifications = apply(MsTeams, type, [params])

    slack_notifications ++ ms_tems_notifications
  end
end

# body = URI.encode_query(%{
#   "code" => "4659483875559.4709218216352.cf1a4cd50b4c61b433c7307ffe553be3763f8a465655fddf7f531b373d1276af",
#   "client_id" => "4659483875559.4686702025457",
#   "client_secret" => "d4b34882b201055a88253f44980b7e1c"
# })

#  HTTPoison.post("https://slack.com/api/oauth.v2.access", body, [{"Content-Type", "application/x-www-form-urlencoded"}])  

# i = Pulsarius.Repo.get(Pulsarius.Incidents.Incident, "bc57195f-c2ee-4905-a9e8-6e4be637d7d3") |> Pulsarius.Repo.preload([monitor: [:configuration]])
# Pulsarius.Notifications.incident_created(i) 
# incident_auto_resolved

# PulsariusWeb.Router.Helpers.incidents_show_path(PulsariusWeb.Endpoint, :show, i.monitor_id, i.id)

# m = Pulsarius.Repo.get(Pulsarius.Monitoring.Monitor, "d8aa7b6a-92f6-48ef-af1c-140be632187f")    
# u = Pulsarius.Repo.get(Pulsarius.Accounts.User, "6bcd832c-68fc-4103-9f66-cc854736bab4") 
# Pulsarius.broadcast("monitor", {:monitor_paused, %{monitor: m, user: u}})
# Pulsarius.broadcast("incidents", {:incident_resolved, %{monitor: m, user: u}})
