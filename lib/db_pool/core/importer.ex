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
    sql_dump_url = Application.get_env(:db_pool, :sql_dump_url)

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

    # download and extract the dump zip file
    File.mkdir_p!(tmp_directory)
    {_, 0} = System.cmd("wget", [sql_dump_url], stderr_to_stdout: true,
                                                cd: tmp_directory)

    sql_dump_filename_gz = sql_dump_url |> String.split("/") |> List.last
    {_, 0} = System.cmd("gzip", ["-d", sql_dump_filename_gz],
                        stderr_to_stdout: true,
                        cd: tmp_directory)

    # import database. Adapter has got no method :(
    sql_dump_filename = sql_dump_filename_gz |> String.replace(".gz", "")
    cmd = "mysql --user root #{database.name} < #{sql_dump_filename}"
    {_, 0} = System.cmd("sh", ["-c", cmd], stderr_to_stdout: true,
                                           cd: tmp_directory)

    # update status
    database
    |> Database.status_changeset("imported")
    |> Repo.update!()

    Logger.info "The database has been imported"
  end
end
