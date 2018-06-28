defmodule DbPoolWeb.DatabaseControllerTest do
  use DbPoolWeb.ConnCase

  alias DbPool.Core

  @create_attrs %{import_log: "some import_log", name: "some name", status: "some status", url: "some url"}
  @update_attrs %{import_log: "some updated import_log", name: "some updated name", status: "some updated status", url: "some updated url"}
  @invalid_attrs %{import_log: nil, name: nil, status: nil, url: nil}

  def fixture(:database) do
    {:ok, database} = Core.create_database(@create_attrs)
    database
  end

  describe "index" do
    test "lists all databases", %{conn: conn} do
      conn = get conn, database_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Databases"
    end
  end

  describe "new database" do
    test "renders form", %{conn: conn} do
      conn = get conn, database_path(conn, :new)
      assert html_response(conn, 200) =~ "New Database"
    end
  end

  describe "create database" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, database_path(conn, :create), database: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == database_path(conn, :show, id)

      conn = get conn, database_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Database"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, database_path(conn, :create), database: @invalid_attrs
      assert html_response(conn, 200) =~ "New Database"
    end
  end

  describe "edit database" do
    setup [:create_database]

    test "renders form for editing chosen database", %{conn: conn, database: database} do
      conn = get conn, database_path(conn, :edit, database)
      assert html_response(conn, 200) =~ "Edit Database"
    end
  end

  describe "update database" do
    setup [:create_database]

    test "redirects when data is valid", %{conn: conn, database: database} do
      conn = put conn, database_path(conn, :update, database), database: @update_attrs
      assert redirected_to(conn) == database_path(conn, :show, database)

      conn = get conn, database_path(conn, :show, database)
      assert html_response(conn, 200) =~ "some updated import_log"
    end

    test "renders errors when data is invalid", %{conn: conn, database: database} do
      conn = put conn, database_path(conn, :update, database), database: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Database"
    end
  end

  describe "delete database" do
    setup [:create_database]

    test "deletes chosen database", %{conn: conn, database: database} do
      conn = delete conn, database_path(conn, :delete, database)
      assert redirected_to(conn) == database_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, database_path(conn, :show, database)
      end
    end
  end

  defp create_database(_) do
    database = fixture(:database)
    {:ok, database: database}
  end
end
