defmodule DbPool.Core.Importer do
  alias DbPool.Core
  alias DbPool.Core.Pool
  alias DbPool.Core.Database
  alias DbPool.Repo

  import DbPool.Utils

  require Logger

  def run(%Database{} = database) do
    Database.status_changeset(database, "importing")
  end

  def start_importing(database) do
    # download database dump using wget
    # import it to database name
    tmp_directory = "/tmp/#{DateTime.utc_now |> DateTime.to_unix}"
    pool = Core.get_active_pool!()
    db_dump_url = pool.db_dump_url

    with :ok <- File.mkdir_p!(tmp_directory),
         {_, 0} <- System.cmd("wget", [db_dump_url], stderr_to_stdout: true, cd: tmp_directory),
         db_dump_filename_gz <- db_dump_url |> String.split("/") |> List.last(),
         {_, 0} = System.cmd("gzip", ["-f", "-d", db_dump_filename_gz], stderr_to_stdout: true, cd: tmp_directory),
         db_dump_filename <- db_dump_filename_gz |> String.replace(".gz", ""),
         :ok <- import_db(pool, database, db_dump_filename, tmp_directory)
    do
      # update status
      database
      |> Database.status_changeset("imported")
      |> Repo.update!()

      Logger.info "The database has been imported"
      Core.remove_errors(pool)
    else
      {msg, error_code} ->
        error_msg = "[#{error_code}] #{msg}"
        Core.log_error(pool, error_msg)
        :error
    end
  end

  defp import_db(%Pool{} = pool, database, db_dump_filename, tmp_directory) do
    case pool.adapter do
      "postgres" -> import_postgres_db(database, db_dump_filename, tmp_directory)
      "mysql" -> import_mysql_db(database, db_dump_filename, tmp_directory)
    end
  end

  defp import_postgres_db(%Database{} = database, filename, dir) do
    pool = Core.get_active_pool!()

    with {_, 0} <- System.cmd("createdb", [database.name], env: get_envs(pool)),
         {_, 0} <- System.cmd("psql", ["-d", database.name, "-f", "./#{filename}"], stderr_to_stdout: true, cd: dir, env: get_envs(pool))
    do
      :ok
    else
      {msg, error_code} ->
        Logger.error("[#{error_code}] #{msg}")
        {"couldn't import database", 1}
    end
  end

  defp import_mysql_db(%Database{} = database, filename, dir) do
    # create database if it doesn't exist
    pool = Core.get_active_pool!()
    config = [database: database.name, username: pool.username, password: pool.password]
    case Ecto.Adapters.MySQL.storage_up(config) do
      :ok ->
        Logger.info "The database has been created"
      {:error, :already_up} ->
        Logger.info "The database has already been created"
      {:error, term} when is_binary(term) ->
        raise "The database couldn't be created: #{term}"
      {:error, term} ->
        raise "The database couldn't be created: #{inspect term}"
    end

    # import database. Adapter has got no method :(
    cmd = "mysql #{database.name} < #{filename}"
    case System.cmd("sh", ["-c", cmd], stderr_to_stdout: true, cd: dir, env: get_envs(pool)) do
      {_, 0} ->
        :ok

      {msg, error_code} ->
        Logger.error("[#{error_code}] #{msg}")
        {"couldn't import database", 1}
    end
  end
end
