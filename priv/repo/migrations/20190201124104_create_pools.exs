defmodule DbPool.Repo.Migrations.CreatePools do
  use Ecto.Migration

  def change do
    create table(:pools) do
      add :adapter, :string
      add :name_prefix, :string
      add :db_dump_url, :string
      add :username, :string
      add :password, :string
      add :host, :string
      add :active, :boolean, default: false, null: false
      add :errored, :boolean, default: false, null: false
      add :error_message, :string

      timestamps()
    end

    create unique_index(:pools, :adapter)
    create unique_index(:pools, :active, where: "active = true")
  end
end
