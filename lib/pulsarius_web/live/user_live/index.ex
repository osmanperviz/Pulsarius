defmodule PulsariusWeb.UserLive.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.Accounts
  alias Pulsarius.Accounts.User

  @impl true
  def mount(_params, _session, %{assigns: %{account: account}} = socket) do
    socket =
      socket
      |> assign(:users, list_users(account.id))
      |> assign(:pending_invitations, Accounts.fetch_invitation_by_type(account.id, :email))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, assign(socket, :users, list_users(socket.assigns.account.id))}
  end

  def handle_event("generate-invitation-link", _params, socket) do
    {:noreply,
     socket
     |> push_event("copy_user_invitation_link", %{
       link:
         Routes.user_invitation_url(
           PulsariusWeb.Endpoint,
           :join,
           socket.assigns.account.invitation_token
         )
     })
     |> put_flash(
       :info,
       "Invitation link copied!"
     )}
  end

  defp list_users(account_id) do
    Accounts.list_users(account_id)
  end
end
