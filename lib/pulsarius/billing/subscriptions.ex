defmodule Pulsarius.Billing.Subscriptions do
  @moduledoc """
  The Subscription model will be responsible for representing and handling business rules for a user’s subscription.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Accounts.Account
  alias Pulsarius.Billing.Plans

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "subscriptions" do
    field :active, :boolean, default: false
    field :stripe_id, :string

    belongs_to :plan, Plans,
      foreign_key: :plan_id,
      type: :binary_id

    belongs_to :account, Account,
      foreign_key: :account_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(subscriptions, attrs) do
    subscriptions
    |> cast(attrs, [:active, :stripe_id])
    |> validate_required([:active, :stripe_id])
  end
end
