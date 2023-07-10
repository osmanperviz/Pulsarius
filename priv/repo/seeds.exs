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
  alias Pulsarius.Monitoring

  Code.require_file("spec/support/test_helpers.ex")

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

  monitor_params = %{
    "name" => "Review",
    "status" => :active,
    "configuration" => %{
      "frequency_check_in_seconds" => "60",
      "url_to_monitor" => "https://www.review-app.gigalixirapp.com/health-check",
      "email_notification" => true,
      "sms_notification" => true,
      "alert_rule" => :becomes_unavailable,
      "alert_condition" => "",
      "ssl_expiry_date" => DateTime.utc_now(),
      "ssl_notify_before_in_days" => "30",
      "domain_expiry_date" => DateTime.utc_now(),
      "domain_notify_before_in_days" => "30"
    }
  }

  {:ok, monitor} = Monitoring.create_monitor(account, monitor_params)

  start_date = Timex.now() |> Timex.beginning_of_day() |> Timex.shift(days: -29)
  end_date = Timex.now()
  Pulsarius.Abc.generate_seed_data(monitor, start_date, end_date)

  # monitor = Pulsarius.Monitoring.get_monitor!("bd273919-447c-4518-9d43-9f11a613f16f")
  #     end_date = Timex.now()
  #   start_date = Timex.now() |> Timex.beginning_of_day() |> Timex.shift(days: -29)
  # Pulsarius.Abc.generate_seed_data(monitor, start_date, end_date)
  #  monitor = Pulsarius.Monitoring.get_monitor!("bd273919-447c-4518-9d43-9f11a613f16f")

  free_plan = %{
    charging_interval: 1000,
    benefits: [
      "5 min. monitoring interval",
      "Keyword monitor",
      "SSL monitor",
      "Single-user account"
    ],
    description: "Perfect for personal projects. No need for a credit card!",
    name: "Freelancer",
    price_in_cents: 10,
    stripe_price_id: "some stripe_price_id",
    type: :freelancer
  }

  small_team_plan = %{
    charging_interval: 12,
    description: "Ideal for individuals running their own businesses and passionate hobbyists.",
    benefits: [
      "5 min. monitoring interval",
      "Keyword monitor",
      "SSL monitor",
      "Single-user account"
    ],
    name: "Small Team",
    price_in_cents: 1000,
    stripe_price_id: "price_1MW0ZxGzlqiGxcQvOecmXEDM",
    type: :small_team
  }

  bussiness_plan = %{
    charging_interval: 12,
    description: "Designed for compact teams seeking seamless collaboration.",
    benefits: [
      "5 min. monitoring interval",
      "Keyword monitor",
      "SSL monitor",
      "Single-user account"
    ],
    name: "Bussiness",
    price_in_cents: 10000,
    stripe_price_id: "price_1MVJnGGzlqiGxcQvvte35iVf",
    type: :bussines
  }

  {:ok, _plan} = Pulsarius.Billing.create_plans(free_plan)
  Pulsarius.Billing.create_plans(bussiness_plan)
  Pulsarius.Billing.create_plans(small_team_plan)
end
