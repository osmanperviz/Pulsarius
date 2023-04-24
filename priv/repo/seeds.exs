# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Pulsarius.Repo.insert!(%Pulsarius.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

if Mix.env() == :dev do
  alias Pulsarius.Accounts

  params = %{
    "type" => "freelancer",
    "users" => [
      %{
        "email" => "test@test.test",
        "first_name" => "test",
        "last_name" => "test",
        "status" => "registered",
        "admin" => "true"
      }
    ]
  }

  {:ok, account} = Accounts.create_account(params)

  free_plan = %{
    charging_interval: 1000,
    description: "Free Plan",
    name: "Freelancer",
    price_in_cents: 10,
    stripe_price_id: "some stripe_price_id",
    type: :freelancer
  }

  small_team_plan = %{
    charging_interval: 12,
    description: "Small Team",
    name: "Small Team",
    price_in_cents: 1000,
    stripe_price_id: "price_1MW0ZxGzlqiGxcQvOecmXEDM",
    type: :small_team
  }

  bussiness_plan = %{
    charging_interval: 12,
    description: "Bussiness Plan",
    name: "Bussiness",
    price_in_cents: 10000,
    stripe_price_id: "price_1MVJnGGzlqiGxcQvvte35iVf",
    type: :bussines
  }

  {:ok, plan} = Pulsarius.Billing.create_plans(free_plan)
  Pulsarius.Billing.create_plans(small_team_plan)
  Pulsarius.Billing.create_plans(bussiness_plan)
end
