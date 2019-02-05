defmodule DbPool.Core do
  @moduledoc """
  The Core context.
  """

  import Ecto.Query, warn: false
  alias DbPool.Repo

  alias DbPool.Core.Pool
  alias DbPool.Core.Database
  alias DbPool.Core.BulkCreator
  alias DbPool.Core.Importer
  alias DbPool.Core.Deleter

  require Logger

  @limit 25

  @doc """
  Returns the list of databases.

  ## Examples

      iex> list_databases()
      [%Database{}, ...]

  """
  def list_databases(status, page) do
    filtered =
    if status == "all" do
      Database
    else
      Database
      |> Ecto.Query.where(status: ^status)
    end

    filtered
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

  def get_databases() do
    Database
    |> Ecto.Query.where(status: "imported")
    |> Repo.all
    |> Enum.map(&format_resource/1)
  end

  @doc """
  Returns database status by status

  ## Examples

      iex> database_stats()
      [{"imported", 27}, {"deleted", 29}, {"deleting", 1}]
  """
  def database_stats() do
    Database
    |> Ecto.Query.select([p], {p.status, count(p.id)})
    |> Ecto.Query.group_by(:status)
    |> Repo.all
    |> Enum.map(fn({k, v}) ->
      {(k |> String.to_atom), v}
    end)
  end

  def list_pools(), do: Repo.all(Pool)

  def get_pool!(id), do: Repo.get!(Pool, id)

  def get_active_pool() do
    Pool
    |> Ecto.Query.where(active: true)
    |> Repo.one()
  end

  def get_active_pool!() do
    Pool
    |> Ecto.Query.where(active: true)
    |> Repo.one!()
  end

  def change_pool(%Pool{} = pool), do: Pool.changeset(pool, %{})

  def create_pool(%Pool{} = pool, attrs \\ %{}) do
    pool
    |> Pool.changeset(attrs)
    |> Repo.insert()
  end

  def update_pool(%Pool{} = pool, attrs \\ %{}) do
    pool
    |> Pool.changeset(attrs)
    |> Repo.insert()
  end

  def get_error() do
    case get_active_pool() do
      nil ->
        {"", 0}

      pool ->
        {pool.error_message, pool.errored}
    end
  end

  def log_error(%Pool{} = pool, error_msg) do
    Logger.error(error_msg)
    unless pool.errored do
      pool
      |> Pool.error_changeset(%{errored: true, error_message: String.slice(error_msg, 0..2048)})
      |> Repo.update!()
    else
      pool
    end
  end

  def remove_errors(%Pool{} = pool) do
    if pool.errored do
      pool
      |> Pool.error_changeset(%{errored: false})
      |> Repo.update!()
    else
      pool
    end
  end

  defp format_resource(%Database{} = database) do
    %{
      external_id: "#{database.id}",
      value: database.name
    }
  end
end
