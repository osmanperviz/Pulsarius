defmodule Pulsarius.Billing.Plans do
  @moduledoc """
  The Plan model will be responsible for representing and handling business rules for the subscription options we will offer.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "plans" do
    field :charging_interval, :integer
    field :description, :string
    field :name, :string
    field :price_in_cents, :integer
    field :stripe_price_id, :string
    field :benefits, {:array, :string}
    field :type, Ecto.Enum, values: [:freelancer, :small_team, :bussines]

    timestamps()
  end

  @doc false
  def changeset(plans, attrs) do
    plans
    |> cast(attrs, [
      :name,
      :description,
      :charging_interval,
      :price_in_cents,
      :stripe_price_id,
      :benefits
    ])
    |> validate_required([:name, :price_in_cents, :stripe_price_id, :benefits])
  end
end
