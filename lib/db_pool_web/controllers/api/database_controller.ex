defmodule DbPoolWeb.API.DatabaseController do
  use DbPoolWeb, :controller

  alias DbPool.Core

  def create(conn, _params) do
    Task.start fn ->
      Core.create_in_bulk()
    end

    json(conn, :ok)
  end

  def delete(conn, %{"id" => id}) do
    database = Core.get_database!(id)
    {:ok, _database} = Core.delete_database(database)

    json(conn, :ok)
  end

  def reimport(conn, %{"id" => id}) do
    database = Core.get_database!(id)
    { :ok, _database } = Core.import_dump_to_database(database)

    json(conn, :ok)
  end

  def items(conn, _params) do
    databases = Core.get_databases()

    json(conn, databases)
  end
end

