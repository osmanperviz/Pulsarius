defmodule PulsariusWeb.WebhookView do
  use Phoenix.View,
    root: "lib/pulsarius_web/notifications"

  alias PulsariusWeb.Router.Helpers, as: Routes
  import PulsariusWeb.LiveHelpers, only: [humanized_duration: 2]

  def render("incident_created.json", incident) do
    %{
      "text" => "New incident for *#{incident.monitor.name}*",
      "attachments" => [
        %{
          "color" => "#880808",
          "blocks" => [
            %{
              "type" => "section",
              "text" => %{
                "type" => "mrkdwn",
                "text" =>
                  "*Monitor:* #{incident.monitor.name}\n *Cause:* Status #{incident.status_code} \n *Checked URL:*  `#{incident.monitor.configuration.url_to_monitor}` \n *Response:* \n ```#{incident.page_response}``` "
              }
            },
            %{
              "type" => "actions",
              "elements" => [
                %{
                  "type" => "button",
                  "text" => %{
                    "type" => "plain_text",
                    "emoji" => true,
                    "text" => "Acknowledge"
                  },
                  "style" => "primary"
                },
                %{
                  "type" => "button",
                  "text" => %{
                    "type" => "plain_text",
                    "emoji" => true,
                    "text" => "View incident"
                  },
                  "url" =>
                    Routes.incidents_show_url(
                      PulsariusWeb.Endpoint,
                      :show,
                      incident.monitor_id,
                      incident.id
                    )
                }
              ]
            }
          ]
        }
      ]
    }
  end

  def render("incident_auto_resolved.json", incident) do
    %{
      "text" => "Automatically resolved *#{incident.monitor.name}* incident",
      "attachments" => [
        %{
          "color" => "#4BB543",
          "blocks" => [
            %{
              "type" => "section",
              "text" => %{
                "type" => "mrkdwn",
                "text" =>
                  "*Monitor:* #{incident.monitor.name}\n *Cause:* Status #{incident.status_code} \n *Length:* #{humanized_duration(incident.occured_at, incident.resolved_at)}\n *Checked URL:*  `#{incident.monitor.configuration.url_to_monitor}` \n *Response:* \n ```#{incident.page_response}``` "
              }
            },
            %{
              "type" => "actions",
              "elements" => [
                %{
                  "type" => "button",
                  "text" => %{
                    "type" => "plain_text",
                    "emoji" => true,
                    "text" => "View incident"
                  },
                  "url" =>
                    Routes.incidents_show_url(
                      PulsariusWeb.Endpoint,
                      :show,
                      incident.monitor_id,
                      incident.id
                    )
                }
              ]
            }
          ]
        }
      ]
    }
  end

  def render("monitor_paused.json", %{monitor: monitor, user: user}) do
    %{
      "blocks" => [
        %{
          "type" => "section",
          "text" => %{
            "type" => "mrkdwn",
            "text" =>
              "Monitor *#{monitor.name}* is paused by *#{Pulsarius.Accounts.User.full_name(user)}*"
          }
        },
        %{
          "type" => "actions",
          "elements" => [
            %{
              "type" => "button",
              "text" => %{
                "type" => "plain_text",
                "emoji" => true,
                "text" => "View monitor"
              },
              "url" =>
                Routes.monitor_show_url(
                  PulsariusWeb.Endpoint,
                  :show,
                  monitor.id
                )
            }
          ]
        },
        %{
          "type" => "context",
          "elements" => [
            %{
              "type" => "plain_text",
              "text" =>
                "#{Timex.format!(monitor.updated_at, "{WDshort}, {D} {Mshort} at {h24}:{0m}:{0s}")}",
              "emoji" => true
            }
          ]
        }
      ]
    }
  end

  def render("monitor_unpaused.json", %{monitor: monitor, user: user}) do
    %{
      "blocks" => [
        %{
          "type" => "section",
          "text" => %{
            "type" => "mrkdwn",
            "text" =>
              "Monitor *#{monitor.name}* was unpaused by *#{Pulsarius.Accounts.User.full_name(user)}*."
          }
        },
        %{
          "type" => "actions",
          "elements" => [
            %{
              "type" => "button",
              "text" => %{
                "type" => "plain_text",
                "emoji" => true,
                "text" => "View monitor"
              },
              "url" =>
                Routes.monitor_show_url(
                  PulsariusWeb.Endpoint,
                  :show,
                  monitor.id
                )
            }
          ]
        },
        %{
          "type" => "context",
          "elements" => [
            %{
              "type" => "plain_text",
              "text" =>
                "#{Timex.format!(monitor.updated_at, "{WDshort}, {D} {Mshort} at {h24}:{0m}:{0s}")}",
              "emoji" => true
            }
          ]
        }
      ]
    }
  end
end
