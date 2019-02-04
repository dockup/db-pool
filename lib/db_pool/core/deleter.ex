defmodule DbPool.Core.Deleter do
  alias DbPool.Core
  alias DbPool.Core.Database
  alias DbPool.Repo

  require Logger

  def run(%Database{} = database) do
    Database.status_changeset(database, "deleting")
  end

  def start_deleting(database) do
    pool = Core.get_active_pool!()
    try do
      do_start_deleting(database, pool)
      Core.remove_errors(pool)
      :ok
    rescue
      _ ->
        error_msg = "[!] Error Occurred while deleting database"
        Core.log_error(pool, error_msg)
        :error
    end
  end

  def do_start_deleting(database, pool) do
    case pool.adapter do
      "postgres" -> delete_postgres_db(database)
      "mysql" -> delete_mysql_db(database)
    end

    # update status
    database
    |> Database.status_changeset("deleted")
    |> Repo.update!()

    Logger.info "The database has been deleted"
  end

  defp delete_postgres_db(%Database{} = database) do
    {_, 0} = System.cmd("dropdb", [database.name])
  end

  defp delete_mysql_db(%Database{} = database) do
    # delete database if it exists
    config = [database: database.name, username: "root"]
    case Ecto.Adapters.MySQL.storage_down(config) do
      :ok ->
        Logger.info "The database has been deleted"
      {:error, :already_down} ->
        Logger.info "The database has already been deleted"
      {:error, term} when is_binary(term) ->
        raise "The database couldn't be deleted: #{term}"
      {:error, term} ->
        raise "The database couldn't be deleted: #{inspect term}"
    end
  end
end
