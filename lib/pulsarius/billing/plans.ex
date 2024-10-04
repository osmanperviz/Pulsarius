defmodule Pulsarius.Billing.Plans do
  @moduledoc """
  The Plan model will be responsible for representing and handling business rules for the subscription options we will offer.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "plans" do
    field :description, :string
    field :name, :string
    field :type, Ecto.Enum, values: [:freelancer, :small_team, :bussines]
    field :monthly_price_in_cents, :integer
    field :yearly_price_in_cents, :integer
    field :monthly_stripe_price_id, :string
    field :yearly_stripe_price_id, :string
    field :benefits, {:array, :string}

    timestamps()
  end

  @attrs [
    :name,
    :description,
    :monthly_price_in_cents,
    :yearly_price_in_cents,
    :monthly_stripe_price_id,
    :yearly_stripe_price_id,
    :benefits
  ]

  @doc false
  def changeset(plans, attrs) do
    plans
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
