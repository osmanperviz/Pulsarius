defmodule Pulsarius.StatusPages.StatusPage do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Monitoring.Monitor

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "status_pages" do
    field :name, :string
    field :homepage_url, :string
    field :layout, Ecto.Enum, values: [:vertical, :horizontal], default: :vertical
    field :logo_url, :string
    field :status_history_in_days, :integer, default: 10

    field :is_public, :boolean, default: false

    belongs_to :account, Pulsarius.Accounts.Account,
      foreign_key: :account_id,
      type: :binary_id

    has_many :monitors, Monitor, on_replace: :nilify

    timestamps()
  end

  @doc false
  def changeset(status_page, attrs) do
    status_page
    |> cast(attrs, [
      :name,
      :homepage_url,
      :is_public,
      :layout,
      :logo_url,
      :status_history_in_days,
      :account_id
    ])
    |> validate_required([
      :name,
      :homepage_url,
      :is_public,
      :layout,
      :status_history_in_days,
      :account_id
    ])
    |> Ecto.Changeset.put_assoc(:monitors, attrs["monitors"])
  end

  def create_changeset(status_page, attrs) do
    status_page
    |> cast(attrs, [
      :name,
      :homepage_url,
      :is_public,
      :layout,
      :logo_url,
      :status_history_in_days,
      :account_id
    ])
    |> validate_required([
      :name,
      :homepage_url,
      :is_public,
      :layout,
      :status_history_in_days,
      :account_id
    ])
    |> Ecto.Changeset.put_assoc(:monitors, attrs["monitors"])
  end

  def status_history_in_days do
    [
      "10 days": 10,
      "20 days": 20,
      "30 days": 30,
      "90 days": 90
    ]
  end
end
