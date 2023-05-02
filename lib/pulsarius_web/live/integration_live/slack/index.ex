defmodule PulsariusWeb.IntegrationsLive.Slack.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.Integrations

  @impl true
  def mount(_params, _session, socket) do
    account = Pulsarius.Repo.preload(socket.assigns.account, :integrations)

    {:ok, assign(socket, :integrations, account.integrations)}
  end

  def handle_event("remove-channel", %{"id" => id}, socket) do
    integration = Integrations.get_integration!(id)

    {:ok, _integration} = Integrations.delete_integration(integration)

    integrations =
      socket.assigns.account
      |> Pulsarius.Repo.preload(:integrations)
      |> Map.get(:integrations)

    {:noreply,
     socket
     |> assign(:integrations, integrations)
     |> put_flash(:info, "You have successfully removed the slack channel integration")}
  end

  def render(assigns) do
    ~H"""
    <div class="col-lg-12">
      <div class="card box pb-2 pt-2 w-100">
        <div class="card-header pb-3 d-flex justify-content-between">
          <div class="d-flex gap-3">
            <div style="width: 50px ">
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
              <h5 class=" mb-0">Slack</h5>
              <p class="abc">
                Post new Pulsarius incidents to Slack channel
              </p>
            </div>
          </div>
          <div class="mt-3">
            <%= link("Add another",
              to: slack_link(),
              class: "btn btn-md btn-primary"
            ) %>
          </div>
        </div>

        <%= if Enum.any?(@integrations) do %>
          <div class="card-body pt-4 pb-4 d-flex">
            <ul class="list-group w-100">
              <%= for integration <- @integrations do %>
                <li class="list-group-item p-3 d-flex justify-content-between">
                  <div>Pulsarius</div>
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
              Your Slack integration list is empty. Please add a Puslarius integration to receive incident notifications on Slack.
            </p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp slack_link() do
    client_id = Application.get_env(:pulsarius, :slack_integration)[:client_id]

    "https://slack.com/oauth/v2/authorize?client_id=#{client_id}&scope=users:read,users:read.email,incoming-webhook&user_scope="
  end
end
