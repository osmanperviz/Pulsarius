defmodule PulsariusWeb.InvitationLive.New do
  use PulsariusWeb, :live_view

  alias Pulsarius.Accounts.{User, UserInvitation}
  alias Pulsarius.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    invitation = Repo.get(UserInvitation, id) |> Repo.preload(:account)

    {:noreply,
     socket
     |> assign(:page_title, "Finish Registration")
     |> assign(:account, invitation.account)
     |> assign(:user, %User{email: invitation.email})}
  end

  def render(assigns) do
    ~H"""
    <div class="col-lg-12 mb-5 mt-2">
      <h3>Welcome to Pulsarius</h3>
    </div>
    <div class="col-lg-12 d-flex ">
      <div class="col-lg-4">
        <h5>Registration</h5>
        <p class="count-down">Please finish your Registration by providing missing data.</p>
      </div>
      <div class="col-lg-8">
        <div class="card box pb-2 pt-2 w-100">
          <div class="card-body pt-4 pb-4">
            <.live_component
              module={PulsariusWeb.UserLive.FormComponent}
              id="user-ivite"
              action={@live_action}
              user={@user}
              account={@account}
              return_to={Routes.user_index_path(PulsariusWeb.Endpoint, :index)}
            />
          </div>
        </div>
      </div>
    </div>
    """
  end
end
