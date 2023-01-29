defmodule PulsariusWeb.CheckoutLive.BillingComponents do
  use PulsariusWeb, :component

  def price_box(assigns) do
    ~H"""
    <div class="card mb-4 rounded-3 shadow-sm">
      <div class="card-header py-3">
        <h4 class="my-0 fw-normal"><%= @plan.name %></h4>
      </div>
      <div class="card-body">
        <h1 class="card-title pricing-card-title">
          $<%= @plan.price_in_cents %><small class="text-muted fw-light">/mo</small>
        </h1>
        <ul class="list-unstyled mt-3 mb-4">
          <li>10 users included</li>
          <li>2 GB of storage</li>
          <li>Email support</li>
          <li>Help center access</li>
        </ul>
        <.link
          href={Routes.checkout_index_path(@socket, :index, %{plan_id: @plan.id})}
          class={"w-100 btn btn-lg btn-outline-primary #{if @current_plan.id == @plan.id, do: "disabled"}"}
        >
          <%= @button_title %>
        </.link>
      </div>
    </div>
    """
  end
end
