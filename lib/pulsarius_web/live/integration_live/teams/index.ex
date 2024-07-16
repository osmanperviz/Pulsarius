defmodule PulsariusWeb.IntegrationsLive.Teams.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.Integrations

  @impl true
  def mount(_params, _session, socket) do
    account = Pulsarius.Repo.preload(socket.assigns.account, :ms_teams_integrations)

    {:ok, assign(socket, :integrations, account.ms_teams_integrations)}
  end

  @impl true
  def handle_event("remove-channel", %{"id" => id}, socket) do
    integration = Integrations.get_integration!(id)

    {:ok, _integration} = Integrations.delete_integration(integration)

    integrations =
      socket.assigns.account
      |> Pulsarius.Repo.preload(:ms_teams_integrations)
      |> Map.get(:ms_teams_integrations)

    {:noreply,
     socket
     |> assign(:integrations, integrations)
     |> put_flash(:info, "You have successfully removed the MSTeams channel integration")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-lg-12">
      <div class="card box pb-2 pt-2 w-100">
        <div class="card-header pb-3 d-flex justify-content-between">
          <div class="d-flex gap-2">
            <div style="width: 50px p-1">
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
            <div class="">
              <h5 class="mb-0 mt-1">Slack</h5>
              <p class="abc">
                Post new Pulsarius incidents to MSTeams channel
              </p>
            </div>
          </div>
          <div class="mt-3">
            <%= link("Add another",
              to: Routes.integrations_teams_new_path(PulsariusWeb.Endpoint, :new),
              class: "btn btn-md btn-primary"
            ) %>
          </div>
        </div>

        <%= if Enum.any?(@integrations) do %>
          <div class="card-body pt-4 pb-4 d-flex">
            <ul class="list-group w-100">
              <%= for integration <- @integrations do %>
                <li class="list-group-item p-3 d-flex justify-content-between">
                  <div><%= integration.name %></div>
                  <div class="gap-3 d-flex">
                    <p class="gray-color"><%= integration.channel_name %></p>
                    <a href="#" phx-click="remove-channel" phx-value-id={integration.id}>Remove</a>
                  </div>
                </li>
              <% end %>
            </ul>
          </div>
        <% else %>
          <div class="card-body pt-4 pb-4">
            <p class="text-center">
              Your MS Teams integration list is empty. Please add a Puslarius integration to receive incident notifications on Teams.
            </p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
