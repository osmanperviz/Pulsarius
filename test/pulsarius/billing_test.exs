defmodule Pulsarius.BillingTest do
  use Pulsarius.DataCase

  alias Pulsarius.Billing

  describe "plans" do
    alias Pulsarius.Billing.Plans

    import Pulsarius.BillingFixtures

    @invalid_attrs %{charging_interval: nil, description: nil, name: nil, price_in_cents: nil, stripe_price_id: nil}

    test "list_plans/0 returns all plans" do
      plans = plans_fixture()
      assert Billing.list_plans() == [plans]
    end

    test "get_plans!/1 returns the plans with given id" do
      plans = plans_fixture()
      assert Billing.get_plans!(plans.id) == plans
    end

    test "create_plans/1 with valid data creates a plans" do
      valid_attrs = %{charging_interval: 42, description: "some description", name: "some name", price_in_cents: 42, stripe_price_id: "some stripe_price_id"}

      assert {:ok, %Plans{} = plans} = Billing.create_plans(valid_attrs)
      assert plans.charging_interval == 42
      assert plans.description == "some description"
      assert plans.name == "some name"
      assert plans.price_in_cents == 42
      assert plans.stripe_price_id == "some stripe_price_id"
    end

    test "create_plans/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billing.create_plans(@invalid_attrs)
    end

    test "update_plans/2 with valid data updates the plans" do
      plans = plans_fixture()
      update_attrs = %{charging_interval: 43, description: "some updated description", name: "some updated name", price_in_cents: 43, stripe_price_id: "some updated stripe_price_id"}

      assert {:ok, %Plans{} = plans} = Billing.update_plans(plans, update_attrs)
      assert plans.charging_interval == 43
      assert plans.description == "some updated description"
      assert plans.name == "some updated name"
      assert plans.price_in_cents == 43
      assert plans.stripe_price_id == "some updated stripe_price_id"
    end

    test "update_plans/2 with invalid data returns error changeset" do
      plans = plans_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.update_plans(plans, @invalid_attrs)
      assert plans == Billing.get_plans!(plans.id)
    end

    test "delete_plans/1 deletes the plans" do
      plans = plans_fixture()
      assert {:ok, %Plans{}} = Billing.delete_plans(plans)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_plans!(plans.id) end
    end

    test "change_plans/1 returns a plans changeset" do
      plans = plans_fixture()
      assert %Ecto.Changeset{} = Billing.change_plans(plans)
    end
  end
end
