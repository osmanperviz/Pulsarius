defmodule Pulsarius.Mailer do
  use Swoosh.Mailer, otp_app: :pulsarius
  use Phoenix.Swoosh, view: PulsariusWeb.EmailsView, layout: {PulsariusWeb.EmailsView, :layout}

    # @spec profile_added(Profile.t(), recipient()) :: Swoosh.Email.t()
  def incident_created(_incident, _recipient) do
    base_email()
    |> subject("Incident occured!")
    |> render_body("incident_created.html")
  end

   defp base_email do
    new()
    |> from({"Pulsarius", "info@pulsarius.com"})
  end
end
