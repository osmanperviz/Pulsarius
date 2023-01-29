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
        "status" => "registered"
      }
    ]
  }

  {:ok, account} = Accounts.create_account(params)

  free_plan = %{
    charging_interval: 1000,
    description: "Free Plan",
    name: "Freelancer",
    price_in_cents: 10,
    stripe_price_id: "some stripe_price_id"
  }

  small_team_plan = %{
    charging_interval: 12,
    description: "Smal Team",
    name: "Smaal Team",
    price_in_cents: 1000,
    stripe_price_id: "some stripe_price_id"
  }

  bussiness_plan = %{
    charging_interval: 12,
    description: "Bussiness Plan",
    name: "Bussiness",
    price_in_cents: 10000,
    stripe_price_id: "some stripe_price_id"
  }

  {:ok, plan} = Pulsarius.Billing.create_plans(free_plan)

  Pulsarius.Billing.create_plans(small_team_plan)
  Pulsarius.Billing.create_plans(bussiness_plan)

  {:ok, _sub} =
    Pulsarius.Billing.create_subscriptions(account, plan, %{
      active: true,
      stripe_id: "some stripe_id"
    })
end
