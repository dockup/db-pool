defmodule DbPool.Core.Importer do
  alias DbPool.Core.Database
  alias DbPool.Repo

  require Logger

  def run(%Database{} = database) do
    Database.status_changeset(database, "importing")
  end

  def start_importing(database) do
    # download database dump using wget
    # import it to database name
    tmp_directory = "/tmp/#{DateTime.utc_now |> DateTime.to_unix}"
    db_dump_url = Application.get_env(:db_pool, :db_dump_url)
    db_adapter = Application.get_env(:db_pool, :db_adapter)

    # download and extract the dump zip file
    File.mkdir_p!(tmp_directory)
    {_, 0} = System.cmd("wget", [db_dump_url], stderr_to_stdout: true,
                        cd: tmp_directory)

    db_dump_filename_from_url = db_dump_url |> String.split("/") |> List.last

    extension = db_dump_filename_from_url |> String.split(".") |> List.last
    case extension do
      "gz" ->
        {msg, code} = System.cmd("gzip", ["-d", db_dump_filename_from_url],
                                 stderr_to_stdout: true,
                                 cd: tmp_directory)
        cond do
          code == 1 and !String.contains?(msg, "already exists") ->
            raise "[!] Error Occurred while decompressing db dump"
          true -> :ok
        end

      _ ->
        Logger.info "No need to extract"
    end

    db_dump_filename = db_dump_filename_from_url |> String.replace(".gz", "")

    case db_adapter do
      "postgres" -> import_postgres_db(database, db_dump_filename, tmp_directory)
      "mysql" -> import_mysql_db(database, db_dump_filename, tmp_directory)
    end

    # update status
    database
    |> Database.status_changeset("imported")
    |> Repo.update!()

    Logger.info "The database has been imported"
  end

  defp import_postgres_db(%Database{} = database, filename, dir) do
    case System.cmd("createdb", [database.name]) do
      {_, 0} ->
        Logger.info("The database has been created")
      {_, 1} ->
        Logger.info("The database couldn't be created or it already exists")
    end
    {_, 0} = System.cmd("psql", ["-d", database.name, "-f", "./#{filename}"], stderr_to_stdout: true, cd: dir)
  end

  defp import_mysql_db(%Database{} = database, filename, dir) do
    # create database if it doesn't exist
    config = [database: database.name, username: "root"]
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
    cmd = "mysql --user root #{database.name} < #{filename}"
    {_, 0} = System.cmd("sh", ["-c", cmd], stderr_to_stdout: true,
                                           cd: dir)
  end
end
