defmodule PulsariusWeb.UserSessionController do
  use PulsariusWeb, :controller

  alias Pulsarius.Accounts
  alias Pulsarius.Accounts.User

  def create(conn, %{"email" => email} = _params) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_magic_link(user)

      conn
      |> put_status(:created)
    else
      # register user
    end
  end

  def new(conn, %{"token" => token} = _params) do
    case Accounts.get_user_by_email_token(token) do
      %User{} = _user ->
        conn
        |> put_session(:user_token, token)
        |> redirect(to: Routes.monitor_index_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "That link didn't seem to work. Please try again.")
        |> redirect(to: Routes.monitor_index_path(conn, :index))
    end
  end

end
