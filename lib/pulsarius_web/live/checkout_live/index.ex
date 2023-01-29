defmodule PulsariusWeb.CheckoutLive.Index do
  use PulsariusWeb, :live_view

  import PulsariusWeb.CheckoutLive.BillingComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"plan_id" => plan_id} = params) do
    plan = Pulsarius.Billing.get_plans!(plan_id)

    socket
    |> assign(:page_title, "Checkout Page")
    |> assign(:plan, plan)
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Checkout Page")
    |> assign(:plan, nil)
  end
end
