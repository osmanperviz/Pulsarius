defmodule Pulsarius.StatusPages.StatusPage do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Monitoring.Monitor

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "status_pages" do
    field :name, :string
    field :description, :string

    field :is_public, :boolean, default: false

    belongs_to :account, Pulsarius.Accounts.Account,
      foreign_key: :account_id,
      type: :binary_id

    has_many :monitors, Monitor, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(status_page, attrs) do
    status_page
    |> cast(attrs, [:name, :description, :url, :is_public])
    |> validate_required([:name, :description, :url, :is_public])
  end
end
