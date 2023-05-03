defmodule PulsariusWeb.IntegrationsLive.Index do
  use PulsariusWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    account = Pulsarius.Repo.preload(socket.assigns.account, :integrations)

    has_slack_integrated? =
      Enum.filter(account.integrations, &(&1.type == :slack))
      |> Enum.any?()

    has_ms_teams_integrated? =
      Enum.filter(account.integrations, &(&1.type == :ms_teams))
      |> Enum.any?()

    {:ok,
     socket
     |> assign(:has_slack_integrated?, has_slack_integrated?)
     |> assign(:has_ms_teams_integrated?, has_ms_teams_integrated?)}
  end

  def render(assigns) do
    ~H"""
    <div class="col-lg-12 mb-5">
      <h3>Integrations</h3>
    </div>
    <div class="col-lg-12 d-flex gap-3">
      <div class="col-lg-6 ">
        <div class="card box pb-2 pt-2 w-100">
          <div class="card-header pb-0 d-flex">
            <h4 class="">Slack</h4>
            <div style="margin-left: auto;" class="pb-2">
              <%= if @has_slack_integrated? do %>
                <%= link("Channel list",
                  to: Routes.integrations_slack_index_path(PulsariusWeb.Endpoint, :index),
                  class: "integration-button btn btn-light btn-sm"
                ) %>
              <% else %>
                <%= link("Add Slack",
                  to: slack_link(),
                  class: "integration-button btn btn-light btn-sm"
                ) %>
              <% end %>
            </div>
          </div>

          <div class="card-body pt-4 pb-4 d-flex gap-3">
            <div style="width: 100px ">
              <svg
                enable-background="new 0 0 2447.6 2452.5"
                viewBox="0 0 2447.6 2452.5"
                xmlns="http://www.w3.org/2000/svg"
              >
                <g clip-rule="evenodd" fill-rule="evenodd">
                  <path
                    d="m897.4 0c-135.3.1-244.8 109.9-244.7 245.2-.1 135.3 109.5 245.1 244.8 245.2h244.8v-245.1c.1-135.3-109.5-245.1-244.9-245.3.1 0 .1 0 0 0m0 654h-652.6c-135.3.1-244.9 109.9-244.8 245.2-.2 135.3 109.4 245.1 244.7 245.3h652.7c135.3-.1 244.9-109.9 244.8-245.2.1-135.4-109.5-245.2-244.8-245.3z"
                    fill="#36c5f0"
                  />
                  <path
                    d="m2447.6 899.2c.1-135.3-109.5-245.1-244.8-245.2-135.3.1-244.9 109.9-244.8 245.2v245.3h244.8c135.3-.1 244.9-109.9 244.8-245.3zm-652.7 0v-654c.1-135.2-109.4-245-244.7-245.2-135.3.1-244.9 109.9-244.8 245.2v654c-.2 135.3 109.4 245.1 244.7 245.3 135.3-.1 244.9-109.9 244.8-245.3z"
                    fill="#2eb67d"
                  />
                  <path
                    d="m1550.1 2452.5c135.3-.1 244.9-109.9 244.8-245.2.1-135.3-109.5-245.1-244.8-245.2h-244.8v245.2c-.1 135.2 109.5 245 244.8 245.2zm0-654.1h652.7c135.3-.1 244.9-109.9 244.8-245.2.2-135.3-109.4-245.1-244.7-245.3h-652.7c-135.3.1-244.9 109.9-244.8 245.2-.1 135.4 109.4 245.2 244.7 245.3z"
                    fill="#ecb22e"
                  />
                  <path
                    d="m0 1553.2c-.1 135.3 109.5 245.1 244.8 245.2 135.3-.1 244.9-109.9 244.8-245.2v-245.2h-244.8c-135.3.1-244.9 109.9-244.8 245.2zm652.7 0v654c-.2 135.3 109.4 245.1 244.7 245.3 135.3-.1 244.9-109.9 244.8-245.2v-653.9c.2-135.3-109.4-245.1-244.7-245.3-135.4 0-244.9 109.8-244.8 245.1 0 0 0 .1 0 0"
                    fill="#e01e5a"
                  />
                </g>
              </svg>
            </div>
            <div>
              <p class="abc">
                Stay on top of your website's performance by receiving real-time updates on any Pulsarius incidents directly in your Slack channels.
              </p>
            </div>
          </div>
        </div>
      </div>

      <div class="col-lg-6 ">
        <div class="card box pb-2 pt-2 w-100">
          <div class="card-header pb-0 d-flex">
            <h4 class="">MsTeams</h4>
            <div style="margin-left: auto;" class="pb-2">
                <%= if @has_ms_teams_integrated? do %>
                <%= link("Channel list",
                  to: Routes.integrations_teams_index_path(PulsariusWeb.Endpoint, :index),
                  class: "integration-button btn btn-light btn-sm"
                ) %>
              <% else %>
                 <a
                href={Routes.integrations_teams_new_path(PulsariusWeb.Endpoint, :new)}
                class="btn btn-light btn-sm integration-button"
              >
                Add MsTeams
              </a>
                <% end %>
            </div>
          </div>
          <div class="card-body pt-4 pb-4 d-flex">
            <div style="width: 100px ">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="80px" height="60px">
                <path
                  fill="#5c6bc0"
                  d="M41.5 13A3.5 3.5 0 1 0 41.5 20 3.5 3.5 0 1 0 41.5 13zM4 40l23 4V4L4 8V40z"
                /><path
                  fill="#fff"
                  d="M21 16.27L21 19 17.01 19.18 16.99 31.04 14.01 30.95 14.01 19.29 10 19.45 10 16.94z"
                /><path
                  fill="#5c6bc0"
                  d="M36 14c0 2.21-1.79 4-4 4-1.2 0-2.27-.53-3-1.36v-5.28c.73-.83 1.8-1.36 3-1.36C34.21 10 36 11.79 36 14zM38 23v11c0 0 1.567 0 3.5 0 1.762 0 3.205-1.306 3.45-3H45v-8H38zM29 20v17c0 0 1.567 0 3.5 0 1.762 0 3.205-1.306 3.45-3H36V20H29z"
                />
              </svg>
            </div>
            <div>
              <p class="abc">
                Effortlessly track website incidents and receive instant alerts on MS Teams with Pulsarius, so you can stay ahead of any potential issues.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp slack_link() do
    client_id = Application.get_env(:pulsarius, :slack_integration)[:client_id]

    "https://slack.com/oauth/v2/authorize?client_id=#{client_id}&scope=users:read,users:read.email,incoming-webhook&user_scope="
  end
end
