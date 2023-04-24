defmodule PulsariusWeb.UserInvitationController do
  use PulsariusWeb, :controller

  alias Pulsarius.Accounts
  alias Pulsarius.Accounts.Account
  alias Pulsarius.Accounts.UserInvitation

  def join(conn, %{"invitation_token" => invitation_token}) do
    case Accounts.get_by_account_invitation_token(invitation_token) do
      %Account{} = account ->
        redirect(conn, to: Routes.invitation_join_path(conn, :join, account))

      _ ->
        conn
        |> put_layout(false)
        |> put_root_layout(false)
        |> put_status(:not_found)
        |> put_view(PulsariusWeb.ErrorView)
    end
  end

  def accept(conn, %{"token" => token}) do
    case Accounts.fetch_invitation_from_token(token) do
      %UserInvitation{status: "pending"} = invitation ->
        redirect(conn, to: Routes.invitation_new_path(conn, :new, invitation))

      _ ->
        conn
        |> put_layout(false)
        |> put_root_layout(false)
        |> put_status(:not_found)
        |> put_view(PulsariusWeb.ErrorView)
    end
  end
end
