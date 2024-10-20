defmodule PulsariusWeb.LoginLive.New do
  use PulsariusWeb, :live_view

  alias Pulsarius.Accounts
  alias Pulsarius.Accounts.{User, Account}

  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok, assign(socket, magic_link_send: false)}
  end

  def handle_event("send-magic-link", %{"email" => email} = _params, socket) do
    case Accounts.get_user_by_email(email) do
      nil ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "The email address you entered is not registered with us. Please check the email you've entered or consider signing up if you haven't already."
         )}

      user ->
        Accounts.deliver_magic_link(user)
        {:noreply, assign(socket, magic_link_send: true)}
    end
  end

  def render(assigns) do
    ~H"""
    <%= if assigns.magic_link_send do %>
      <.success_message />
    <% else %>
      <.login_form />
    <% end %>
    """
  end

  def login_form(assigns) do
    ~H"""
    <div
      class="col-lg-12 d-flex h-100 align-items-center justify-content-center"
      phx-mounted={
        JS.show(transition: {"fade-in duration-000", "opacity-0", "opacity-100"}, time: 50000)
      }
    >
      <div class="col-lg-5">
        <div class="card box pb-2 pt-2 w-100">
          <div class=" mt-3 pb-0 text-center">
            <h4 class="">Welcome back</h4>
            <p class="gray-color" style="font-size: 0.8rem">
              First time here?
              <.link
                href={Routes.registration_new_path(PulsariusWeb.Endpoint, :new)}
                class="ml-2 text-decoration-none"
              >
                Sign up for free
              </.link>
            </p>
          </div>
          <div class="card-body pb-4 pt-0">
            <.form :let={f} id="magic-link-form" phx-submit="send-magic-link">
              <div class="col-lg-12">
                <%= label(f, :email, class: "mb-1") %>
                <%= text_input(f, :email,
                  class: "form-control search-monitors",
                  placeholder: "Your work email"
                ) %>
                <%= error_tag(f, :email) %>
              </div>

              <div class="form-group mt-4 text-center">
                <%= submit("Send me a magic link",
                  phx_disable_with: "Sending...",
                  class: "btn btn-primary btn-lg btn-block w-100"
                ) %>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def success_message(assigns) do
    ~H"""
    <div
      class="col-lg-12 d-flex h-100 align-items-center justify-content-center"
      style="transition: opacity 7s;"
    >
      <div class="col-lg-5">
        <div class="card box pb-2 pt-2 w-100">
          <div class=" mt-3 pb-0 text-center">
            <h4 class="">Success!</h4>
            <p class="gray-color" style="font-size: 0.8rem">
              Magic link sent. Check your email.
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
