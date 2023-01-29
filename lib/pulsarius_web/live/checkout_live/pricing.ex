defmodule PulsariusWeb.CheckoutLive.Pricing do
  use PulsariusWeb, :live_view

  import PulsariusWeb.CheckoutLive.BillingComponents

  @impl true
  def mount(_params, _session, socket) do
    plans = Pulsarius.Billing.list_plans()
    account = socket.assigns.account |> Pulsarius.Repo.preload([{:subscription, :plan}])

    {:ok,
     socket
     |> assign(:page_title, "Pricing Page")
     |> assign(:plans, plans)
     |> assign(:current_plan, account.subscription.plan)}
  end

  defp apply_action(socket, :pricing, params) do
    {:ok}
  end

    def button_title(current_plan_id, plan_id) do
        if current_plan_id == plan_id, do: "Your Plan", else: "Select Plan"
    end
end
