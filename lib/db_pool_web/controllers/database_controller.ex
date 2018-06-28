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
        |> redirect(to: database_path(conn, :show, database))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    database = Core.get_database!(id)
    render(conn, "show.html", database: database)
  end

  def edit(conn, %{"id" => id}) do
    database = Core.get_database!(id)
    changeset = Core.change_database(database)
    render(conn, "edit.html", database: database, changeset: changeset)
  end

  def update(conn, %{"id" => id, "database" => database_params}) do
    database = Core.get_database!(id)

    case Core.update_database(database, database_params) do
      {:ok, database} ->
        conn
        |> put_flash(:info, "Database updated successfully.")
        |> redirect(to: database_path(conn, :show, database))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", database: database, changeset: changeset)
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
