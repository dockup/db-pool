defmodule DbPool.Core.Database do
  use Ecto.Schema
  import Ecto.Changeset


  schema "databases" do
    field :import_log, :string
    field :name, :string
    field :status, :string
    field :url, :string

    timestamps()
  end

  @statuses ["importing", "imported",
             "deleting", "deleted"]

  @doc false
  def changeset(database, attrs) do
    database
    |> cast(attrs, [:name, :url, :import_log])
    |> validate_required([:name, :url, :import_log])
    |> unique_constraint(:name)
    |> unique_constraint(:url)
  end

  @doc false
  def status_changeset(database, status) do
    database
    |> cast(%{status: status}, [:status])
    |> validate_inclusion(:status, @statuses)
  end
end
