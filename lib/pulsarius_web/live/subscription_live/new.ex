defmodule PulsariusWeb.SubscriptionLive.New do
  use PulsariusWeb, :live_view

  import PulsariusWeb.SubscriptionLive.BillingComponents
  alias Pulsarius.Accounts.{User, Account}
  alias Pulsarius.Billing
  alias Pulsarius.Accounts
  alias Pulsarius.Billing.Subscriptions

  @impl true
  def mount(_params, _session, socket) do
    Pulsarius.subscribe("webhook_processed")

    stripe_id = create_stripe_customer(socket.assigns.account, socket.assigns.current_user)

    {:ok, setup_intent} = Stripe.SetupIntent.create(%{customer: stripe_id})
    {:ok, assign(socket, :client_secret, setup_intent.client_secret)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{"plan_id" => plan_id} = params) do
    plan = Pulsarius.Billing.get_plans!(plan_id)

    socket
    |> assign(:page_title, "Checkout Page")
    |> assign(:choosen_plan, plan)
    |> assign(:retry, false)
  end

  defp apply_action(socket, :new, params) do
    socket
    |> assign(:page_title, "Checkout Page")
    |> assign(:plan, nil)
  end

  @doc """
  Handle incoming events from the stripe webhook processor.
  """
  @impl true
  def handle_info({:stripe_event, event}, socket) do
    event
    |> filter_event_for_current_customer(socket.assigns.account)
    |> Map.get(:type)
    |> case do
      "payment_method.attached" ->
        if socket.assigns.retry do
          {:noreply, socket}
        else
          create_subscription(socket, event.data.object.id)
        end

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event(
        "payment-confirmed",
        _params,
        socket
      ) do
    {:noreply, redirect(socket, to: Routes.monitor_index_path(socket, :index))}
  end

  defp create_stripe_customer(account, current_user) when is_nil(account.stripe_id) do
    {:ok, stripe_customer} =
      Stripe.Customer.create(%{
        email: current_user.email,
        name: User.full_name(current_user)
      })

    {:ok, account} = Accounts.assign_stripe_id(account, stripe_customer.id)

    stripe_customer.id
  end

  defp create_stripe_customer(account, _current_user) do
    account.stripe_id
  end

  defp create_subscription(socket, payment_method_id) do
    %{account: account, choosen_plan: choosen_plan} = socket.assigns

    {:ok, subscription} =
      Stripe.Subscription.create(%{
        customer: account.stripe_id,
        items: [%{price: choosen_plan.stripe_price_id}],
        default_payment_method: payment_method_id
      })

    {:noreply, socket}
  end

  defp filter_event_for_current_customer(event, account) do
    if Map.get(event.data.object, :customer) == account.stripe_id do
      event
    else
      Map.put(event, :type, nil)
    end
  end
end

# %{          
#   "amount" => 1000,
#   "amount_details" => %{"tip" => %{}},
#   "automatic_payment_methods" => nil,
#   "canceled_at" => nil,
#   "cancellation_reason" => nil,
#   "capture_method" => "automatic",
#   "client_secret" => "pi_3MX6ovGzlqiGxcQv1EjsS4PC_secret_yFZZdL9TokGa1GfolQE6eMI0l",
#   "confirmation_method" => "automatic",
#   "created" => 1675359817,
#   "currency" => "usd",
#   "description" => nil,
#   "id" => "pi_3MX6ovGzlqiGxcQv1EjsS4PC",
#   "last_payment_error" => nil,
#   "livemode" => false,
#   "next_action" => nil,
#   "object" => "payment_intent",
#   "payment_method" => "pm_1MX6paGzlqiGxcQv34JdBS42",
#   "payment_method_types" => ["card"],
#   "processing" => nil,
#   "receipt_email" => nil,
#   "setup_future_usage" => nil,
#   "shipping" => nil,
#   "source" => nil,
#   "status" => "succeeded"
# }

# Stripe.Subscription.create(%{
#   customer: "cus_NIkMB7OaUuMVJQ",
#   items: [%{price: "price_1MW0ZxGzlqiGxcQvOecmXEDM"}]
# })
