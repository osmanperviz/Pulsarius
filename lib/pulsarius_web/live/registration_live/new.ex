defmodule PulsariusWeb.RegistrationLive.New do
  use PulsariusWeb, :live_view

  alias Pulsarius.Accounts
  alias Pulsarius.Accounts.{User, Account}

  def render(assigns) do
    ~H"""
    <div class="col-lg-12 d-flex h-100 align-items-center justify-content-center">
      <div class="col-lg-6 ">
        <div class="card box pb-2 pt-2 w-100 ">
          <div class=" mt-3 pb-0 text-center">
            <h6 class="">Sign Up</h6>
            <p class="gray-color" style="font-size: 0.8rem">
              Why don't we introduce ourselves?
            </p>
          </div>
          <div class="card-body pt-4 pb-4 ">
            <.form :let={f} for={@form} id="sign-up-form" phx-submit="sign-up">
              <div class="d-flex row">
                <div class="col-lg-6">
                  <%= label(f, :first_name, class: "mb-2") %>
                  <%= text_input(f, :first_name, class: "form-control search-monitors") %>
                  <%= error_tag(f, :first_name) %>
                </div>
                <div class="col-lg-6">
                  <%= label(f, :last_name, class: "mb-2") %>
                  <%= text_input(f, :last_name, class: "form-control search-monitors") %>
                  <%= error_tag(f, :last_name) %>
                </div>
                <div class="col-lg-6">
                  <%= inputs_for f, :account, fn a -> %>
                    <%= label(a, :organization_name, class: "mb-2 mt-3") %>
                    <%= text_input(a, :organization_name, class: "form-control search-monitors") %>

                    <%= error_tag(a, :organization_name) %>
                  <% end %>
                </div>
                <div class="col-lg-6">
                  <%= label(f, :phone_number, class: "mb-2 mt-3") %>
                  <%= text_input(f, :phone_number, class: "form-control search-monitors") %>
                  <%= error_tag(f, :phone_number) %>
                </div>
                <div class="col-lg-12">
                  <%= label(f, :email, class: "mt-4 mb-2") %>
                  <%= text_input(f, :email, class: "form-control search-monitors") %>
                  <%= error_tag(f, :email) %>
                </div>
              </div>

              <div class="form-group mt-4 text-center">
                <%= submit("Sign up",
                  phx_disable_with: "Saving...",
                  class: "btn btn-primary btn-lg btn-block w-100"
                ) %>
              </div>
              <p class="gray-color mt-3 text-center" style="font-size: 0.8rem">
                Already have account?
                <.link
                  href={Routes.login_new_path(PulsariusWeb.Endpoint, :new)}
                  class="ml-2 text-decoration-none"
                >
                  Login
                </.link>
              </p>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user(%User{account: %Account{}})

    socket =
      socket
      |> assign(:form, changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("sign-up", %{"user" => params}, socket) do
    case Accounts.register_organization(params) do
      {:ok, %{user: user}} ->
        Accounts.deliver_welcome_email(user)

        {:noreply,
         socket
         |> put_flash(:success, "You have successfully registered your organization.")
         |> redirect(to: Routes.registration_success_path(socket, :success))}

      {:error, :account, changeset} ->
        {:noreply, assign(socket, :form, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user(%User{account: %Account{}}, user_params)
    {:noreply, assign(socket, :form, Map.put(changeset, :action, :validate))}
  end
end
