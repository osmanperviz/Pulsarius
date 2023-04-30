defmodule Pulsarius.Integrations.Integration do
  @moduledoc """
  This module representing a single slack or MS Teams channel and holding data related to that channel
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Accounts.Account

  schema "integrations" do
    field :name, :string
    field :channel_name, :string
    field :channel_id, :string
    field :type, Ecto.Enum, values: [:slack, :ms_teams]
    field :webhook_url, :string

    belongs_to :account, Account,
      foreign_key: :account_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [:name, :channel_id, :type, :channel_name, :webhook_url])
    |> validate_required([:type, :name, :webhook_url])
  end
end
