defmodule DbPool.Core.BulkCreator do
  import Ecto.Query, warn: false

  alias DbPool.Core
  alias DbPool.Core.Pool
  alias DbPool.Core.Database
  alias DbPool.Repo

  require Logger

  def run() do
    case Core.get_active_pool() do
      nil ->
        Logger.warn("[!] No Pool Found. Won't be creating any databases.")
        {:error, "No Pool Found. Won't be creating any databases"}
      pool ->
        do_run(pool)
        :ok
    end
  end

  def do_run(%Pool{} = pool) do
    latest_database =
      Database
      |> where([d], like(d.name, ^pool.name_prefix))
      |> order_by([desc: :id])
      |> first()
      |> Repo.one()

    current_sequence =
      case latest_database do
        nil -> 0
        _ ->
          latest_database.name
          |> String.replace(pool.name_prefix, "")
          |> String.to_integer
      end

    # TODO: The number 10 should be configurable
    # ecto multi to the rescue
    Ecto.Multi.new
    |> Ecto.Multi.insert(:d1, database_changeset(current_sequence, 1))
    |> Ecto.Multi.insert(:d2, database_changeset(current_sequence, 2))
    |> Ecto.Multi.insert(:d3, database_changeset(current_sequence, 3))
    |> Ecto.Multi.insert(:d4, database_changeset(current_sequence, 4))
    |> Ecto.Multi.insert(:d5, database_changeset(current_sequence, 5))
    |> Ecto.Multi.insert(:d6, database_changeset(current_sequence, 6))
    |> Ecto.Multi.insert(:d7, database_changeset(current_sequence, 7))
    |> Ecto.Multi.insert(:d8, database_changeset(current_sequence, 8))
    |> Ecto.Multi.insert(:d9, database_changeset(current_sequence, 9))
    |> Ecto.Multi.insert(:d10, database_changeset(current_sequence, 10))
    |> Repo.transaction
  end

  defp database_changeset(current_sequence, increment_by) do
    pool = Core.get_active_pool!()

    name = "#{pool.name_prefix}#{current_sequence + increment_by}"
    attrs = %{name: name, status: "importing"}
    Database.bulk_insert_changeset(%Database{}, attrs)
  end
end
