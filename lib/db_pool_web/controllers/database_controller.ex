defmodule DbPoolWeb.DatabaseController do
  use DbPoolWeb, :controller

  alias DbPool.Core
  alias DbPool.Core.Database

  def index(conn, _params) do
    databases = Core.list_databases()
    render(conn, "index.html", databases: databases)
  end

  def new(conn, _params) do
    changeset = Core.change_database(%Database{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"database" => database_params}) do
    case Core.create_database(database_params) do
      {:ok, database} ->
        conn
        |> put_flash(:info, "Database created successfully.")
        |> redirect(to: database_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def import_dump(conn, %{"database_id" => id}) do
    database = Core.get_database!(id)

    case Core.import_dump_to_database(database) do
      {:ok, database} ->
        conn
        |> put_flash(:info, "Database queued for importing.")
        |> redirect(to: database_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:info, "Failed to import, not sure why!")
        |> redirect(to: database_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    database = Core.get_database!(id)
    {:ok, _database} = Core.delete_database(database)

    conn
    |> put_flash(:info, "Database deleted successfully.")
    |> redirect(to: database_path(conn, :index))
  end
end
