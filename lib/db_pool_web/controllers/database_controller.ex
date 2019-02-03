defmodule DbPoolWeb.DatabaseController do
  use DbPoolWeb, :controller

  alias DbPool.Core
  alias DbPool.Core.Database

  def index(conn, params) do
    page = String.to_integer(params["page"] || "1")
    status = params["status"] || "all"
    stats = Core.database_stats()

    databases = Core.list_databases(status, page)
    render(conn, "index.html", databases: databases,
                               page: page, stats: stats,
                               status: status)
  end

  def new(conn, _params) do
    changeset = Core.change_database(%Database{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"database" => database_params}) do
    case Core.create_database(database_params) do
      {:ok, _database} ->
        conn
        |> put_flash(:info, "Database created successfully.")
        |> redirect(to: database_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def import_dump(conn, %{"database_id" => id} = params) do
    page = String.to_integer(params["page"] || "1")
    status = params["status"] || "all"

    database = Core.get_database!(id)

    case Core.import_dump_to_database(database) do
      {:ok, _database} ->
        conn
        |> put_flash(:info, "Database queued for importing.")
        |> redirect(to: database_path(conn, :index, page: page, status: status))
      {:error, _} ->
        conn
        |> put_flash(:info, "Failed to import, not sure why!")
        |> redirect(to: database_path(conn, :index, page: page, status: status))
    end
  end

  def delete(conn, %{"id" => id} = params) do
    page = String.to_integer(params["page"] || "1")
    status = params["status"] || "all"

    database = Core.get_database!(id)
    {:ok, _database} = Core.delete_database(database)

    conn
    |> put_flash(:info, "Database deleted successfully.")
    |> redirect(to: database_path(conn, :index, page: page, status: status))
  end

  def bulk(conn, _params) do
    case Core.create_in_bulk() do
      {:ok, _databases} ->
        conn
        |> put_flash(:info, "Databases created successfully.")
        |> redirect(to: database_path(conn, :index))
      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Failed to create :(")
        |> redirect(to: database_path(conn, :index))
      {:error, msg} ->
        conn
        |> put_flash(:error, msg)
        |> redirect(to: database_path(conn, :index))
    end
  end
end
