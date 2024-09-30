defmodule Pulsarius.Accounts.PolicyTest do
  use Pulsarius.DataCase
  alias Pulsarius.Accounts.Policy

  alias Pulsarius.{BillingFixtures, AccountsFixtures}
  alias Pulsarius.{Monitoring, Accounts}

  import Mock

  describe "monitoring policy" do
    setup do
      plan = BillingFixtures.plans_fixture(%{rules: %{max_monitors: 1, max_users: 1}})
      account = Pulsarius.AccountsFixtures.account_fixture()

      BillingFixtures.subscriptions_fixture(account, plan, %{status: "active"})

      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          account: account
        }
      }

      {:ok, socket: socket}
    end

    test "can? returns true when monitor limit is not exceeded", %{socket: socket} do
      with_mock Monitoring, list_monitoring: fn _account_id -> [] end do
        result = Policy.can?(socket.assigns.account, :save_monitor)

        assert result == true
      end
    end

    test "can? returns false when monitor limit is exceeded", %{socket: socket} do
      with_mock Monitoring, list_monitoring: fn _account_id -> [%{}, %{}, %{}, %{}] end do
        result = Policy.can?(socket.assigns.account, :save_monitor)

        assert result == false
      end
    end
  end

  describe "user policy" do
    setup do
      plan = BillingFixtures.plans_fixture(%{rules: %{max_monitors: 1, max_users: 1}})
      account = AccountsFixtures.account_fixture()
      _subsctription = BillingFixtures.subscriptions_fixture(account, plan, %{status: "active"})
      _user = AccountsFixtures.user_fixture(account)

      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          account: account
        }
      }

      {:ok, socket: socket}
    end

    test "can? returns true when users limit is not exceeded", %{socket: socket} do
      with_mock Accounts, list_users: fn _account_id -> [] end do
        result = Policy.can?(socket.assigns.account, :add_user)

        assert result == true
      end
    end

    test "can? returns false when users limit is exceeded", %{socket: socket} do
      with_mock Accounts, list_users: fn _account_id -> [%{}, %{}] end do
        result = Policy.can?(socket.assigns.account, :add_user)

        assert result == false
      end
    end
  end
end
