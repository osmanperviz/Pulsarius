defmodule PulsariusWeb.InvitationLive.New do
  use Phoenix.LiveView,
    container: {:div, class: "h-100"}

  alias Pulsarius.Accounts.{User, UserInvitation}
  alias Pulsarius.Repo
  alias PulsariusWeb.Router.Helpers, as: Routes

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
    <div class="col-lg-12 d-flex h-100 align-items-center justify-content-center">
      <div class="col-lg-5 ">
        <div class="card box pb-2 pt-2 w-100 ">
          <div class="card-header pb-0 text-center">
            <h6 class="">Welcome to Pulsarius</h6>
            <p class="gray-color" style="font-size: 0.8rem">
              Please finish your Registration by providing missing data.
            </p>
          </div>
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
