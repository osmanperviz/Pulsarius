defmodule Pulsarius.BillingTest do
  use Pulsarius.DataCase

  alias Pulsarius.Billing

  describe "plans" do
    alias Pulsarius.Billing.Plans

    import Pulsarius.BillingFixtures

    @invalid_attrs %{
      charging_interval: nil,
      description: nil,
      name: nil,
      price_in_cents: nil,
      stripe_price_id: nil
    }

    test "list_plans/0 returns all plans" do
      plans = plans_fixture()
      assert Billing.list_plans() == [plans]
    end

    test "get_plans!/1 returns the plans with given id" do
      plans = plans_fixture()
      assert Billing.get_plans!(plans.id) == plans
    end

    test "create_plans/1 with valid data creates a plans" do
      valid_attrs = %{
        charging_interval: 42,
        description: "some description",
        name: "some name",
        price_in_cents: 42,
        stripe_price_id: "some stripe_price_id"
      }

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

      update_attrs = %{
        charging_interval: 43,
        description: "some updated description",
        name: "some updated name",
        price_in_cents: 43,
        stripe_price_id: "some updated stripe_price_id"
      }

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

  describe "subscriptions" do
    alias Pulsarius.Billing.Subscriptions

    import Pulsarius.BillingFixtures

    @invalid_attrs %{active: nil, stripe_id: nil}

    test "list_subscriptions/0 returns all subscriptions" do
      subscriptions = subscriptions_fixture()
      assert Billing.list_subscriptions() == [subscriptions]
    end

    test "get_subscriptions!/1 returns the subscriptions with given id" do
      subscriptions = subscriptions_fixture()
      assert Billing.get_subscriptions!(subscriptions.id) == subscriptions
    end

    test "create_subscriptions/1 with valid data creates a subscriptions" do
      valid_attrs = %{active: true, stripe_id: "some stripe_id"}

      assert {:ok, %Subscriptions{} = subscriptions} = Billing.create_subscriptions(valid_attrs)
      assert subscriptions.active == true
      assert subscriptions.stripe_id == "some stripe_id"
    end

    test "create_subscriptions/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billing.create_subscriptions(@invalid_attrs)
    end

    test "update_subscriptions/2 with valid data updates the subscriptions" do
      subscriptions = subscriptions_fixture()
      update_attrs = %{active: false, stripe_id: "some updated stripe_id"}

      assert {:ok, %Subscriptions{} = subscriptions} =
               Billing.update_subscriptions(subscriptions, update_attrs)

      assert subscriptions.active == false
      assert subscriptions.stripe_id == "some updated stripe_id"
    end

    test "update_subscriptions/2 with invalid data returns error changeset" do
      subscriptions = subscriptions_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Billing.update_subscriptions(subscriptions, @invalid_attrs)

      assert subscriptions == Billing.get_subscriptions!(subscriptions.id)
    end

    test "delete_subscriptions/1 deletes the subscriptions" do
      subscriptions = subscriptions_fixture()
      assert {:ok, %Subscriptions{}} = Billing.delete_subscriptions(subscriptions)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_subscriptions!(subscriptions.id) end
    end

    test "change_subscriptions/1 returns a subscriptions changeset" do
      subscriptions = subscriptions_fixture()
      assert %Ecto.Changeset{} = Billing.change_subscriptions(subscriptions)
    end
  end
end
