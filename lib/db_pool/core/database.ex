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

  @doc false
  def changeset(database, attrs) do
    database
    |> cast(attrs, [:name, :url, :status, :import_log])
    |> validate_required([:name, :url, :status, :import_log])
  end
end
