defmodule PulsariusWeb.UserInvitationController do
  use PulsariusWeb, :controller

  alias Pulsarius.Accounts
  alias Pulsarius.Accounts.UserInvitation

  def accept(conn, %{"token" => token}) do
    %UserInvitation{pending_user: pending_user} = Accounts.fetch_user_from_invitation(token)

    if pending_state?(pending_user) do
      conn
      |> redirect(to: Routes.user_show_path(conn, :edit, pending_user))
    else
      conn
      |> put_layout(false)
      |> put_root_layout(false)
      |> put_status(:not_found)
      |> put_view(PulsariusWeb.ErrorView)
    end
  end

  def pending_state?(user) do
    user.status == :pending
  end
end
