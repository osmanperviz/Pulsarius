defmodule PulsariusWeb.InvitationLive.Join do
  use PulsariusWeb, :live_view

  alias Pulsarius.Accounts
  alias Pulsarius.Accounts.Account
  alias Pulsarius.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"account_id" => account_id}, _url, socket) do
    %Account{} = account = Accounts.get_account!(account_id)

    changeset =
      {:noreply,
       socket
       |> assign(:page_title, "Finish Registration")
       |> assign(:account, account)}
  end

  def handle_event("send-invite", %{"invite_user" => %{"email" => email}}, socket) do
    case Accounts.invite_user_via_email(socket.assigns.account, email) do
      {:ok, invitation} ->
        :ok = broadcast_invitation_created(invitation)

        {:noreply, put_flash(socket, :info, "An invitation is send, please check your email.")}

      _ ->
        {:noreply, put_flash(socket, :error, "Something went wrong please try again.")}
    end
  end

  def render(assigns) do
    ~H"""
     <.live_component
      module={PulsariusWeb.UserLive.InviteUserFormComponent}
      id={:invite_user}
      account={@account}
      title="You are Invited!"
      message="Join Your team and make a difference."
      button_title="Request Invitation"
    />
    """
  end

  defp broadcast_invitation_created(invitation) do
    Pulsarius.broadcast(
      "invitations",
      {:user_invitation_created, invitation}
    )
  end
end
