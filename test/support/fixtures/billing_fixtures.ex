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
        charging_interval: 42,
        description: "some description",
        name: "some name",
        price_in_cents: 42,
        stripe_price_id: "some stripe_price_id"
      })
      |> Pulsarius.Billing.create_plans()

    plans
  end
end
