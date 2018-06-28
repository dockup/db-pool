defmodule DbPool.Repo.Migrations.CreateDatabases do
  use Ecto.Migration

  def change do
    create table(:databases) do
      add :name, :string
      add :url, :string
      add :status, :string, default: "created"
      add :import_log, :text

      timestamps()
    end

    create unique_index(:databases, [:name])
    create unique_index(:databases, [:url])
  end
end
