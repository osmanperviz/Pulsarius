defmodule PulsariusWeb.SubscriptionLive.Pricing do
  use PulsariusWeb, :live_view

  import PulsariusWeb.SubscriptionLive.BillingComponents
  alias Pulsarius.Accounts.Account

  @impl true
  def mount(_params, _session, socket) do
    plans = Pulsarius.Billing.list_plans()
    current_plan = get_plan_from_account(socket.assigns.account, plans)

    feature_lists = Application.fetch_env!(:pulsarius, :feature_plans)

    {:ok,
     socket
     |> assign(:page_title, "Pricing Page")
     |> assign(:plans, plans)
     |> assign(:current_plan, current_plan)
     |> assign(:montly_subscription, true)
     |> assign(:feature_list, feature_lists)}
  end

  def button_title(current_plan_id, plan_id) do
    if current_plan_id == plan_id, do: "Your Plan", else: "Select Plan"
  end

  @impl true
  def handle_event("toggle-subscription", _params, socket) do
    {:noreply, assign(socket, :montly_subscription, !socket.assigns.montly_subscription)}
  end

  defp get_plan_from_account(account, plans) do
    account = account |> Pulsarius.Repo.preload([:subscription])

    if Account.free_plan?(account) do
      Enum.find(plans, &(&1.name == "Freelancer"))
    else
      account = account |> Pulsarius.Repo.preload([{:subscription, :plan}])
      account.subscription.plan
    end
  end
end
