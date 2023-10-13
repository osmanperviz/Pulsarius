defmodule PulsariusWeb.StripeWebhookController do
  @moduledoc """
  The controller for the Stripe Webhooks endpoint.
  """
  use PulsariusWeb, :controller

  @webhook_signing_key Application.get_env(:stripity_stripe, :webhook_signing_key)
  @stripe_service Application.get_env(:live_view_stripe, :stripe_service)

  plug(:assert_body_and_signature)

  @doc """
  Construct a stripe event, if it is valid we notify subscribers.
  """
  def create(conn, _params) do
    Logger.info("Stripe Webhook Controller triggered!")

    case Stripe.Webhook.construct_event(
           conn.assigns[:raw_body],
           conn.assigns[:stripe_signature],
           "whsec_d2a82c11224e8f58fb3df1dc685b10b360646395bdb6a9fd159346fe43f84ee3"
         ) do
      {:ok, %{} = event} ->
        Logger.info("Notifying subcribers about Event: #{IO.inspect(event)}")
        notify_subscribers(event)

      {:error, reason} ->
        Logger.error("Error occured in Strip WebHook: #{IO.inspect(reason)}")
        reason
    end

    conn
    |> send_resp(:created, "")
  end

  # Confirm assigns has a raw_body and stripe_signature key of stype string,
  # otherwise halt execution.
  defp assert_body_and_signature(conn, _opts) do
    case {conn.assigns[:raw_body], conn.assigns[:stripe_signature]} do
      {"" <> _, "" <> _} ->
        conn

      _ ->
        conn
        |> put_status(500)
        |> halt()
    end
  end

  @doc """
  Notify subscribers to "webhook_received" that a webhook has been recieved and
  send the event.
  """
  def notify_subscribers(event) do
    Pulsarius.broadcast("webhook_received", {:event, event})
  end

  @doc """
  Subscribe to further messages from "webhook_received".
  """
  def subscribe_on_webhook_recieved do
    Phoenix.PubSub.subscribe(Pulsarius.PubSub, "webhook_received")
  end
end
