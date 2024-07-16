defmodule PulsariusWeb.SubscriptionLive.Edit do
  use PulsariusWeb, :live_view

  import PulsariusWeb.SubscriptionLive.BillingComponents
  alias Pulsarius.Billing

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:intent, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"plan_id" => plan_id} = _params) do
    choosen_plan = Pulsarius.Billing.get_plans!(plan_id)
    account = Pulsarius.Repo.preload(socket.assigns.account, [:subscription])
    changeset = Billing.change_subscriptions(account.subscription)

    socket
    |> assign(:page_title, "Change Subscription")
    |> assign(:choosen_plan, choosen_plan)
    |> assign(:subscription, account.subscription)
    |> assign(:changeset, changeset)
  end
end
