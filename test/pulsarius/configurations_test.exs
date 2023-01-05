defmodule Pulsarius.ConfigurationsTest do
  use Pulsarius.DataCase

  alias Pulsarius.Configurations

  describe "configuration" do
    alias Pulsarius.Configurations.Configuration

    import Pulsarius.ConfigurationsFixtures

    @invalid_attrs %{frequency_check_in_seconds: nil, url_to_monitor: nil}

    test "list_configuration/0 returns all configuration" do
      configuration = configuration_fixture()
      assert Configurations.list_configuration() == [configuration]
    end

    test "get_configuration!/1 returns the configuration with given id" do
      configuration = configuration_fixture()
      assert Configurations.get_configuration!(configuration.id) == configuration
    end

    test "create_configuration/1 with valid data creates a configuration" do
      valid_attrs = %{frequency_check_in_seconds: 42, url_to_monitor: "some url_to_monitor"}

      assert {:ok, %Configuration{} = configuration} = Configurations.create_configuration(valid_attrs)
      assert configuration.frequency_check_in_seconds == 42
      assert configuration.url_to_monitor == "some url_to_monitor"
    end

    test "create_configuration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Configurations.create_configuration(@invalid_attrs)
    end

    test "update_configuration/2 with valid data updates the configuration" do
      configuration = configuration_fixture()
      update_attrs = %{frequency_check_in_seconds: 43, url_to_monitor: "some updated url_to_monitor"}

      assert {:ok, %Configuration{} = configuration} = Configurations.update_configuration(configuration, update_attrs)
      assert configuration.frequency_check_in_seconds == 43
      assert configuration.url_to_monitor == "some updated url_to_monitor"
    end

    test "update_configuration/2 with invalid data returns error changeset" do
      configuration = configuration_fixture()
      assert {:error, %Ecto.Changeset{}} = Configurations.update_configuration(configuration, @invalid_attrs)
      assert configuration == Configurations.get_configuration!(configuration.id)
    end

    test "delete_configuration/1 deletes the configuration" do
      configuration = configuration_fixture()
      assert {:ok, %Configuration{}} = Configurations.delete_configuration(configuration)
      assert_raise Ecto.NoResultsError, fn -> Configurations.get_configuration!(configuration.id) end
    end

    test "change_configuration/1 returns a configuration changeset" do
      configuration = configuration_fixture()
      assert %Ecto.Changeset{} = Configurations.change_configuration(configuration)
    end
  end
end
