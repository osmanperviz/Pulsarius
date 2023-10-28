defmodule Pulsarius.Mailer do
  use Swoosh.Mailer, otp_app: :pulsarius
  use Phoenix.Swoosh, view: PulsariusWeb.EmailsView, layout: {PulsariusWeb.EmailsView, :layout}

  @type incident :: Incident.t()
  @type invitation :: UserInvitation.t()
  @type recipient :: Swoosh.Email.Recipient.t()

  @support_email "support@pulsarius.com"

  alias Pulsarius.Notifications.Email

  def get_subject(%Email{type: :incident_created, args: _args}),
    do: "Pulsarius ALERT"

  def get_subject(%Email{type: :incident_auto_resolved, args: _args}),
    do: "Pulsarius RESOLVED"

  def get_subject(%Email{type: :user_invitation_created, args: _args}),
    do: "You have been invited to join Pulsarius."

  def get_subject(%Email{type: :send_magic_link, args: _args}),
    do: "Sign in to Pulsarius "

  def get_subject(%Email{type: :send_welcome_email, args: _args}),
    do: "Welcome to Pulsarius"

  def get_subject(%Email{type: :send_test_alert, args: _args}),
    do: "Pulsarius ALERT"

  def get_template(%Email{type: type}), do: "#{type}.html"

  def get_template_assigns(%Email{type: type, args: args}),
    do: Map.merge(%{email_type: type, support_email: @support_email}, args)

  def to_swoosh_email(%Email{recipient: recipient} = email) do
    new()
    |> from({"Pulsarius", get_sender(email)})
    |> to(recipient)
    |> reply_to(@support_email)
    |> subject(get_subject(email))
    |> render_body(get_template(email), get_template_assigns(email))
  end

  defp get_sender(%Email{type: type, args: _args}) do
    alert_email_types = Application.get_env(:pulsarius, :email)[:alert_email_types]
    notification_emails_types = Application.get_env(:pulsarius, :email)[:notification_types]

    cond do
      type in alert_email_types -> "alert@pulsarius.com"
      type in notification_emails_types -> "notification@pulsarius.com"
      true -> "info@pulsarius.com"
    end
  end
end
