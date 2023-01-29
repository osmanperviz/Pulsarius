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

  def payment_form(assigns) do
    ~H"""
    <div>
      <h4>Summary</h4>
      <ul>
        <li>Billing period Annually (~20% off)</li>
        <li><%= @plan.name %> - $84.00 / year</li>
        <li>Subtotal - $84.00</li>
        <li>To pay now $84.00</li>
      </ul>
      <h4 class="mb-3 mt-5">Payment</h4>
      <div class="row gy-3">
        <div class="col-md-6">
          <%= label(@form, :name_on_card, class: "form-label") %>
          <%= text_input(@form, :name_on_card, class: "form-control") %>
          <small class="text-muted">Full name as displayed on card</small>
          <%= error_tag(@form, :name_on_card) %>
        </div>

        <div class="col-md-6">
          <%= label(@form, :card_number, class: "form-label") %>
          <%= text_input(@form, :card_number, class: "form-control") %>
          <%= error_tag(@form, :card_number) %>
        </div>

        <div class="col-md-3">
          <%= label(@form, :cc_expiration, class: "form-label") do %>
            Expiration
          <% end %>
          <%= text_input(@form, :cc_expiration, class: "form-control") %>
          <%= error_tag(@form, :cc_expiration) %>
        </div>

        <div class="col-md-3">
          <%= label(@form, :cc_cvv, class: "form-label") do %>
            CVV
          <% end %>
          <%= text_input(@form, :cc_cvv, class: "form-control") %>
          <%= error_tag(@form, :cc_cvv) %>
        </div>
      </div>
    </div>
    """
  end

  def billing_info_form(assigns) do
    ~H"""
    <div>
      <h4 class="mb-3">Enter billing info.</h4>
      <form class="needs-validation" novalidate>
        <div class="row g-3">
          <div class="col-sm-6">
            <%= label(@form, :first_name, class: "form-label") %>
            <%= text_input(@form, :first_name, class: "form-control", value: @current_user.first_name) %>
            <%= error_tag(@form, :first_name) %>
          </div>

          <div class="col-sm-6">
            <%= label(@form, :last_name, class: "form-label") %>
            <%= text_input(@form, :last_name, class: "form-control", value: @current_user.last_name) %>
            <%= error_tag(@form, :last_name) %>
          </div>

          <div class="col-12">
            <%= label(@form, :email, class: "form-label") %>
            <%= text_input(@form, :email, class: "form-control", value: @current_user.email) %>
            <%= error_tag(@form, :email) %>
          </div>

          <div class="col-12">
            <%= label(@form, :address, class: "form-label") %>
            <%= text_input(@form, :address, class: "form-control") %>
            <%= error_tag(@form, :address) %>
          </div>

          <div class="col-md-5">
            <label for="country" class="form-label">Country</label>
            <select class="form-select" id="country" required>
              <option value="">Choose...</option>
              <option>United States</option>
            </select>
            <div class="invalid-feedback">
              Please select a valid country.
            </div>
          </div>

          <div class="col-md-3">
            <%= label(@form, :zip_code, class: "form-label") %>
            <%= text_input(@form, :zip_code, class: "form-control") %>
            <%= error_tag(@form, :zip_code) %>
          </div>
          <div class="col-md-3">
            <%= label(@form, :city, class: "form-label") %>
            <%= text_input(@form, :city, class: "form-control") %>
            <%= error_tag(@form, :city) %>
          </div>
        </div>

        <hr class="my-4" />

        <hr class="my-4" />

        <button class="w-100 btn btn-primary btn-lg" type="submit">Pay $84.00 with card</button>
      </form>
    </div>
    """
  end
end
