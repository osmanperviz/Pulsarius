defmodule Pulsarius.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.Billing` context.
  """

  @doc """
  Generate a plans.
  """
  def plans_fixture(attrs \\ %{}) do
    {:ok, plans} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        monthly_price_in_cents: 1000,
        yearly_price_in_cents: 10000,
        monthly_stripe_price_id: "monthly_stripe_price_id",
        yearly_stripe_price_id: "yearly_stripe_price_id",
        rules: %{},
        benefits: [
          "5 min. monitoring interval",
          "Keyword monitor",
          "SSL monitor",
          "Single-user account"
        ]
      })
      |> Pulsarius.Billing.create_plans()

    plans
  end

  @doc """
  Generate a subscriptions.
  """
  def subscriptions_fixture(account, plan, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        active: true,
        stripe_id: "some stripe_id",
        current_period_end_at: Timex.now() |> Timex.shift(days: 30)
      })

    {:ok, subscriptions} = Pulsarius.Billing.create_subscriptions(account, plan, attrs)

    subscriptions
  end
end
