defmodule DbPool.Repo.Migrations.CreateDatabases do
  use Ecto.Migration

  def change do
    create table(:databases) do
      add :name, :string
      add :url, :string
      add :status, :string
      add :import_log, :text

      timestamps()
    end

  end
end
