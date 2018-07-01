defmodule DbPool.Core.Deleter do
  alias DbPool.Core.Database
  alias DbPool.Repo

  require Logger

  def run(%Database{} = database) do
    # TODO: We can put this task under supervisor later
    Task.start(__MODULE__, :start_deleting, [database])
    Database.status_changeset(database, "deleting")
  end

  def start_deleting(database) do
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

    # update status
    database
    |> Database.status_changeset("deleted")
    |> Repo.update!()

    Logger.info "The database has been deleted"
  end
end
