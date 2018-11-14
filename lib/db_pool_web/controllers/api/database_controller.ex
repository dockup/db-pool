defmodule DbPoolWeb.API.DatabaseController do
  use DbPoolWeb, :controller

  alias DbPool.Core

  def create(conn, %{"callback" => callback}) do
    Task.start fn ->
      Core.create_in_bulk(callback)
    end

    json(conn, :ok)
  end

  def delete(conn, %{"id" => id}) do
    database = Core.get_database!(id)
    {:ok, _database} = Core.delete_database(database)

    json(conn, :ok)
  end
end
