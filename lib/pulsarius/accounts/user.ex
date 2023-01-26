defmodule Pulsarius.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Accounts.Account

  @type t :: %__MODULE__{
          email: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          status: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :status, Ecto.Enum, values: [:pending, :registered], default: :pending

    belongs_to :account, Account,
      foreign_key: :account_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :status])
    |> validate_required([:first_name, :last_name, :email])
  end

  def invitation_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :status])
    |> validate_required([:email])
  end
end
