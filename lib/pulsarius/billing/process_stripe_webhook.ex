defmodule Pulsarius.Billing.ProcessWebhook do
  @moduledoc """
  The module for processing stripe webhook event data.
  """
  use GenServer

  alias Pulsarius.Billing
  alias Pulsarius.Accounts

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @doc """
  Subscribe to new webhook messages on start.
  """
  def init(state) do
    subscribe_to_webhook_received_topic()

    {:ok, state}
  end

  @doc """
  Notify subscribers that an event has been processed.

  If it is a subscription related event we use the update subscription or create a new one.
  module.
  """
  def handle_info({:event, event}, state) do
    notify_subscribers(event)

    case event.type do
      "customer.updated" -> nil
      "customer.deleted" -> nil
      "customer.subscription.updated" -> nil
      "customer.subscription.deleted" -> nil
      "customer.subscription.created" -> create_subscription(event.data.object)
      _ -> nil
    end

    {:noreply, state}
  end

  @doc """
  Subscribe to further messages from "webhook_processed".
  """
  def subscribe_to_webhook_received_topic do
    Pulsarius.subscribe("webhook_received")
  end

  @doc """
  Notify subscribers to "webhook_processed" that a webhook has been processed and
  send the event.
  """
  def notify_subscribers(event) do
    Pulsarius.broadcast("webhook_processed", {:stripe_event, event})
  end

  defp create_subscription(
         %{customer: customer_stripe_id, plan: %{id: plan_stripe_id}} = stripe_subscription
       ) do
    account = Accounts.fetch_account_by_stripe_id!(customer_stripe_id)
    plan = Billing.fetch_plan_by_stripe_id!(plan_stripe_id)

    Billing.create_subscriptions(account, plan, %{
      stripe_id: stripe_subscription.id,
      status: stripe_subscription.status,
      current_period_end_at: unix_to_naive_datetime(stripe_subscription.current_period_end)
    })
  end

  # Convert unix to naive datetime.
  defp unix_to_naive_datetime(nil), do: nil

  defp unix_to_naive_datetime(datetime_in_seconds) do
    datetime_in_seconds
    |> DateTime.from_unix!()
    |> DateTime.to_naive()
  end
end
