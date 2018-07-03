defmodule DbPool.Repo.Migrations.RemoveUrlAndImportLogFromDatabases do
  use Ecto.Migration

  def change do
    alter table(:databases) do
      remove :url
      remove :import_log
    end
  end
end
