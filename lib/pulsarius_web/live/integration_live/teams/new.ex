defmodule PulsariusWeb.IntegrationsLive.Teams.New do
  use PulsariusWeb, :live_view

  alias Pulsarius.Integrations
  alias Pulsarius.Integrations.Integration

  @impl true
  def mount(_params, _session, socket) do
    changeset = Integrations.change_integration(%Integration{})
    {:ok, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"integration" => integration_params}, socket) do
    case Integrations.create_integration(socket.assigns.account, integration_params) do
      {:ok, integration} ->
        {:noreply,
         socket
         |> put_flash(:success, "You have successfully added slack integration.")
         |> redirect(to: Routes.integrations_teams_index_path(PulsariusWeb.Endpoint, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="">
      <.link
        href={Routes.integrations_index_path(PulsariusWeb.Endpoint, :index)}
        class="btn bg-transparent abc p-0 mb-4"
      >
        <span class="bi-chevron-left"></span> Integrations
      </.link>
    </div>
    <.form :let={f} for={@changeset} id="teams-integration-form" phx-submit="save">
      <div class="col-lg-12 mb-5">
        <h3>Connect Microsoft Teams to Pulsarius</h3>
      </div>
      <div class="col-lg-12 d-flex">
        <div class="col-lg-4 p-3">
          <h5>Integration name</h5>
        </div>
        <div class="col-lg-8">
          <div class="card box pb-2 pt-2 w-100">
            <div class="card-body pt-4 pb-4">
              <%= text_input(f, :name,
                placeholder: "Pronounceable monitor name",
                class: "form-control search-monitors"
              ) %>
            </div>
          </div>
        </div>
      </div>

      <div class="col-lg-12 d-flex mt-3">
        <div class="col-lg-4 p-3">
          <h5>How to</h5>
          <p class="count-down">
            Effortlessly report Pulsarius incidents to your Microsoft Teams channel with our easy-to-use integration. Follow our step-by-step guide to get started today.
          </p>
        </div>
        <div class="col-lg-8">
          <div class="card box pb-2 pt-2 w-100">
            <div class="card-body pt-4 pb-4">
              <p>
                To integrate the Microsoft Teams Incoming Webhook App with Pulsarius, follow these simple steps:
              </p>
              <ul class="list-group list-group-flush ">
                <li class="list-group-item">
                  1. Go to your Microsoft Teams account and select the team and channel where you want to receive Pulsarius incidents.
                </li>
                <li class="list-group-item">
                  2. Select channel where you want to receive Pulsarius incidents.
                </li>
                <li class="list-group-item">
                  3. Click on the "Add" button and give the webhook a name, such as "Pulsarius".
                </li>
                <li class="list-group-item">
                  4. Click "Create" to create the webhook, and copy the unique URL provided
                </li>
                <li class="list-group-item">5. Copy the URL and paste it below.</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <div class="col-lg-12 d-flex mt-3">
        <div class="col-lg-4 p-3">
          <h5>Microsoft Teams Incoming Webhook URL</h5>
          <p class="count-down">
            Paste the Incoming Webhook URL from the Microsoft Teams settings here.
          </p>
        </div>
        <div class="col-lg-8">
          <div class="card box pb-2 pt-2 w-100">
            <div class="card-body pt-4 pb-4">
              <%= text_input(f, :webhook_url,
                placeholder: "Incoming Webhook URL",
                class: "form-control search-monitors"
              ) %>
              <%= hidden_input(f, :type, value: "ms_teams") %>
            </div>
          </div>
        </div>
      </div>
      <div class="col-lg-12 pb-5 text-center">
        <%= submit("Save integration",
          phx_disable_with: "Saving...",
          class: "btn btn-primary btn-lg btn-block"
        ) %>
      </div>
    </.form>
    """
  end
end
