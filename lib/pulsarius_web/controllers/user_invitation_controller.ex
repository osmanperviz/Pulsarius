defmodule PulsariusWeb.UserInvitationController do
  use PulsariusWeb, :controller

  def accept(conn, %{"token" => token}) do
    # Accounts.fetch_user_from_invitation(token)
    # get user
    # get_invitation
    # chnage status of user from :invited to :registered
    # redirect to monitor page
  end
end
