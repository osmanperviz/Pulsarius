defmodule Pulsarius.Mailer do
  use Swoosh.Mailer, otp_app: :pulsarius
  use Phoenix.Swoosh, view: PulsariusWeb.EmailsView, layout: {PulsariusWeb.EmailsView, :layout}

  @type incident :: Incident.t()
  @type invitation :: UserInvitation.t()
  @type recipient :: Swoosh.Email.Recipient.t()

  @support_email "support@pulsarius.com"

  alias Pulsarius.Notifications.Email

  def get_subject(%Email{type: :incident_created, args: %{incident: incident}}),
    do: "Incident occured!"

  def get_subject(%Email{type: :incident_auto_resolved, args: %{incident: incident}}),
    do: "Incident Auto Resolved!"

  def get_subject(%Email{type: :user_invitation_created, args: %{invitation: invitation}}),
    do: "Osman invited you!"

  def get_subject(%Email{type: :send_test_alert, args: %{user: user}}),
    do: "Test alert!"

  def get_template(%Email{type: type}), do: "#{type}.html"

  def get_template_assigns(%Email{type: type, args: args}),
    do: Map.merge(%{email_type: type, support_email: @support_email}, args)

  def to_swoosh_email(%Email{recipient: recipient} = email) do
    base_email()
    |> to(recipient)
    |> reply_to(@support_email)
    |> subject(get_subject(email))
    |> render_body(get_template(email), get_template_assigns(email))
  end

  defp base_email do
    new()
    |> from({"Pulsarius", "info@pulsarius.com"})
  end
end
