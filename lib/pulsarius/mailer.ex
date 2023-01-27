defmodule Pulsarius.Mailer do
  use Swoosh.Mailer, otp_app: :pulsarius
  use Phoenix.Swoosh, view: PulsariusWeb.EmailsView, layout: {PulsariusWeb.EmailsView, :layout}

  # @spec profile_added(Profile.t(), recipient()) :: Swoosh.Email.t()
  def incident_created(_incident, _recipient) do
    base_email()
    |> subject("Incident occured!")
    |> render_body("incident_created.html")
  end

  # @spec profile_added(Profile.t(), recipient()) :: Swoosh.Email.t()
  def incident_auto_resolved(_incident, _recipient) do
    base_email()
    |> subject("Incident Auto Resolved!")
    |> render_body("incident_auto_resolved.html")
  end

  # @spec profile_added(Profile.t(), recipient()) :: Swoosh.Email.t()
  def user_invitation_created(invitation, _recipient) do
    base_email()
    |> subject("Osman invited you!")
    |> render_body("user_invitation_created.html", invitation: invitation)
  end

  defp base_email do
    new()
    |> from({"Pulsarius", "info@pulsarius.com"})
  end
end
