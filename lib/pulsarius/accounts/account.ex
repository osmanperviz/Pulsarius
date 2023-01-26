defmodule Pulsarius.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Accounts.User
  alias Pulsarius.Monitoring.Monitor

  @type t :: %__MODULE__{
          type: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "accounts" do
    field :type, Ecto.Enum, values: [:freelancer, :small, :bussines], default: :freelancer

    has_many :users, User, on_replace: :delete
    has_many :monitors, Monitor, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:type])
    |> validate_required([:type])
    |> cast_assoc(:users)
  end
end
