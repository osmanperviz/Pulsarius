defmodule Pulsarius.IntegrationsTest do
  use Pulsarius.DataCase

  alias Pulsarius.Integrations

  describe "integrations" do
    alias Pulsarius.Integrations.Integration

    import Pulsarius.IntegrationsFixtures

    @invalid_attrs %{channel_name: nil, name: nil, type: nil, webhook_url: nil}

    test "list_integrations/0 returns all integrations" do
      integration = integration_fixture()
      assert Integrations.list_integrations() == [integration]
    end

    test "get_integration!/1 returns the integration with given id" do
      integration = integration_fixture()
      assert Integrations.get_integration!(integration.id) == integration
    end

    test "create_integration/1 with valid data creates a integration" do
      valid_attrs = %{
        channel_name: "some channel_name",
        name: "some name",
        type: "some type",
        webhook_url: "some webhook_url"
      }

      assert {:ok, %Integration{} = integration} = Integrations.create_integration(valid_attrs)
      assert integration.channel_name == "some channel_name"
      assert integration.name == "some name"
      assert integration.type == "some type"
      assert integration.webhook_url == "some webhook_url"
    end

    test "create_integration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Integrations.create_integration(@invalid_attrs)
    end

    test "update_integration/2 with valid data updates the integration" do
      integration = integration_fixture()

      update_attrs = %{
        channel_name: "some updated channel_name",
        name: "some updated name",
        type: "some updated type",
        webhook_url: "some updated webhook_url"
      }

      assert {:ok, %Integration{} = integration} =
               Integrations.update_integration(integration, update_attrs)

      assert integration.channel_name == "some updated channel_name"
      assert integration.name == "some updated name"
      assert integration.type == "some updated type"
      assert integration.webhook_url == "some updated webhook_url"
    end

    test "update_integration/2 with invalid data returns error changeset" do
      integration = integration_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Integrations.update_integration(integration, @invalid_attrs)

      assert integration == Integrations.get_integration!(integration.id)
    end

    test "delete_integration/1 deletes the integration" do
      integration = integration_fixture()
      assert {:ok, %Integration{}} = Integrations.delete_integration(integration)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_integration!(integration.id) end
    end

    test "change_integration/1 returns a integration changeset" do
      integration = integration_fixture()
      assert %Ecto.Changeset{} = Integrations.change_integration(integration)
    end
  end
end
