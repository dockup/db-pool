defmodule DbPool.Core.BulkCreator do
  import Ecto.Query

  alias DbPool.Core.Database
  alias DbPool.Repo

  require Logger

  @prefix "dockup"

  def run() do
    latest_database =
      Database
      |> Ecto.Query.order_by([desc: :id])
      |> Ecto.Query.first
      |> DbPool.Repo.one

    # TODO: Term `dockup` should be project specific
    current_sequence =
      latest_database.name
      |> String.replace(@prefix, "")
      |> String.to_integer

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
    name = "#{@prefix}#{current_sequence + increment_by}"
    attrs = %{name: name, status: "importing"}
    Database.bulk_insert_changeset(%Database{}, attrs)
  end
end
