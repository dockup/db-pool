defmodule DbPool.Core do
  @moduledoc """
  The Core context.
  """

  import Ecto.Query, warn: false
  alias DbPool.Repo

  alias DbPool.Core.Database
  alias DbPool.Core.BulkCreator
  alias DbPool.Core.Importer
  alias DbPool.Core.Deleter

  @limit 25

  @doc """
  Returns the list of databases.

  ## Examples

      iex> list_databases()
      [%Database{}, ...]

  """
  def list_databases(page) do
    Database
    |> Ecto.Query.offset(^((page - 1) * @limit))
    |> Ecto.Query.limit(@limit)
    |> Ecto.Query.order_by([desc: :id])
    |> Repo.all
  end

  @doc """
  Gets a single database.

  Raises `Ecto.NoResultsError` if the Database does not exist.

  ## Examples

      iex> get_database!(123)
      %Database{}

      iex> get_database!(456)
      ** (Ecto.NoResultsError)

  """
  def get_database!(id), do: Repo.get!(Database, id)

  @doc """
  Creates a database.

  ## Examples

      iex> create_database(%{field: value})
      {:ok, %Database{}}

      iex> create_database(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_database(attrs \\ %{}) do
    %Database{}
    |> Database.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a database.

  ## Examples

      iex> update_database(database, %{field: new_value})
      {:ok, %Database{}}

      iex> update_database(database, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_database(%Database{} = database, attrs) do
    database
    |> Database.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Imports a database.

  ## Examples

      iex> import_database(database)
      {:ok, %Database{}}

  """
  def import_dump_to_database(%Database{} = database) do
    database
    |> Importer.run()
    |> Repo.update()
  end

  @doc """
  Deletes a Database.

  ## Examples

      iex> delete_database(database)
      {:ok, %Database{}}

      iex> delete_database(database)
      {:error, %Ecto.Changeset{}}

  """
  def delete_database(%Database{} = database) do
    database
    |> Deleter.run()
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking database changes.

  ## Examples

      iex> change_database(database)
      %Ecto.Changeset{source: %Database{}}

  """
  def change_database(%Database{} = database) do
    Database.changeset(database, %{})
  end

  @doc """
  Creates bunch of databases right away!

  ## Examples

      iex> create_in_bulk()
      {:ok, [%Database{}]}

      iex> create_bulk()
      {:error, [%Ecto.Changeset{}]}

  """
  def create_in_bulk() do
    BulkCreator.run()
  end
end
