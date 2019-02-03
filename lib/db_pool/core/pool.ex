defmodule DbPool.Core.Pool do
  use Ecto.Schema
  import Ecto.Changeset

  @name_prefix ~s(dbpool_database_)

  @supported_adapters ~w(postgres mysql)
  schema "pools" do
    field :active, :boolean, default: true
    field :adapter, :string
    field :name_prefix, :string, default: @name_prefix
    field :db_dump_url, :string
    field :host, :string
    field :password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(pool, attrs) do
    pool
    |> cast(attrs, [:adapter, :name_prefix, :db_dump_url, :username, :password, :host, :active])
    |> validate_required([:adapter, :db_dump_url, :username, :password, :host, :active])
    |> validate_inclusion(:adapter, @supported_adapters)
    |> unique_constraint(:adapter) # only one pool per adapter
    |> unique_constraint(:active) # only one active pool
  end
end
