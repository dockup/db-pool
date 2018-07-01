defmodule DbPool.Core.Importer do
  alias DbPool.Core.Database
  require Logger

  def run(%Database{} = database) do
    Task.start(__MODULE__, :start_importing, [database])
    :timer.sleep(10000)
    Database.status_changeset(database, "importing")
  end

  def start_importing(database) do
    # download database dump using wget
    # import it to database name
    tmp_directory = "/tmp/#{DateTime.utc_now |> DateTime.to_unix}"
    sql_dump_url = Application.get_env(:db_pool, :sql_dump_url)

    File.mkdir!(tmp_directory)
    {_, 0} = System.cmd("wget", [sql_dump_url], stderr_to_stdout: true,
                                                cd: tmp_directory)

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
  end
end
