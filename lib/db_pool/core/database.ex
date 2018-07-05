defmodule DbPool.Core.Database do
  use Ecto.Schema
  import Ecto.Changeset


  schema "databases" do
    field :name, :string
    field :status, :string

    timestamps()
  end

  @statuses ["importing", "imported",
             "deleting", "deleted"]

  @doc false
  def changeset(database, attrs) do
    database
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  @doc false
  def status_changeset(database, status) do
    database
    |> cast(%{status: status}, [:status])
    |> validate_inclusion(:status, @statuses)
  end

  @doc false
  def bulk_insert_changeset(database, attrs) do
    database
    |> cast(attrs, [:name, :status])
    |> validate_required([:name, :status])
    |> unique_constraint(:name)
    |> validate_inclusion(:status, @statuses)
  end
end
