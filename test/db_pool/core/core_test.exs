defmodule DbPool.CoreTest do
  use DbPool.DataCase

  alias DbPool.Core

  describe "databases" do
    alias DbPool.Core.Database

    @valid_attrs %{import_log: "some import_log", name: "some name", status: "some status", url: "some url"}
    @update_attrs %{import_log: "some updated import_log", name: "some updated name", status: "some updated status", url: "some updated url"}
    @invalid_attrs %{import_log: nil, name: nil, status: nil, url: nil}

    def database_fixture(attrs \\ %{}) do
      {:ok, database} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_database()

      database
    end

    test "list_databases/0 returns all databases" do
      database = database_fixture()
      assert Core.list_databases() == [database]
    end

    test "get_database!/1 returns the database with given id" do
      database = database_fixture()
      assert Core.get_database!(database.id) == database
    end

    test "create_database/1 with valid data creates a database" do
      assert {:ok, %Database{} = database} = Core.create_database(@valid_attrs)
      assert database.import_log == "some import_log"
      assert database.name == "some name"
      assert database.status == "some status"
      assert database.url == "some url"
    end

    test "create_database/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_database(@invalid_attrs)
    end

    test "update_database/2 with valid data updates the database" do
      database = database_fixture()
      assert {:ok, database} = Core.update_database(database, @update_attrs)
      assert %Database{} = database
      assert database.import_log == "some updated import_log"
      assert database.name == "some updated name"
      assert database.status == "some updated status"
      assert database.url == "some updated url"
    end

    test "update_database/2 with invalid data returns error changeset" do
      database = database_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_database(database, @invalid_attrs)
      assert database == Core.get_database!(database.id)
    end

    test "delete_database/1 deletes the database" do
      database = database_fixture()
      assert {:ok, %Database{}} = Core.delete_database(database)
      assert_raise Ecto.NoResultsError, fn -> Core.get_database!(database.id) end
    end

    test "change_database/1 returns a database changeset" do
      database = database_fixture()
      assert %Ecto.Changeset{} = Core.change_database(database)
    end
  end
end
