defmodule PulsariusWeb.UserLive.InviteUserFormComponent do
  use PulsariusWeb, :live_component

  alias Pulsarius.Accounts
  alias Ueberauth.Strategy.Passwordless

  def handle_event("save", %{"invite_user" => %{"email" => email} = invite_user_params}, socket) do
    {:ok, token} = Passwordless.create_token(email)
    invite_user_params = Map.merge(invite_user_params, %{"token" => token})

    case Accounts.invite_user(socket.assigns.account, invite_user_params) do
      {:ok, user_invitation} ->
        # brodcast message and send email
        {:noreply,
         socket
         |> put_flash(:info, "Invite sent!")
         |> push_redirect(to: Routes.user_index_path(socket, :index))}

      {:error, error} ->
        socket
         |> put_flash(:info, "Something went wrong!")
         |> push_redirect(to: Routes.user_index_path(socket, :index))}

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={:invite_user} id="user-invite-form" phx-submit="save" phx-target={@myself}>
        <%= label(f, :email) %>
        <%= text_input(f, :email, class: "form-control") %>
        <%= error_tag(f, :email) %>
      </.form>
    </div>
    """
  end
end
