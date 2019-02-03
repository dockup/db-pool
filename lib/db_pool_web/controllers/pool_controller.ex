defmodule DbPoolWeb.PoolController do
  use DbPoolWeb, :controller

  alias DbPool.Core
  alias DbPool.Core.Pool

  def index(conn, _params) do
    pools = Core.list_pools()
    render conn, "index.html", pools: pools
  end

  def new(conn, _params) do
    changeset = Core.change_pool(%Pool{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"pool" => pool_params}) do
    case Core.create_pool(%Pool{}, pool_params) do
      {:ok, pool} ->
        render conn, "show.html", pool: pool

      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def show(conn, %{"id" => id}) do
    pool = Core.get_pool!(id)
    render conn, "show.html", pool: pool
  end

  def edit(conn, %{"id" => id}) do
    pool = Core.get_pool!(id)
    changeset = Core.change_pool(pool)
    render conn, "edit.html", changeset: changeset, pool: pool
  end

  def update(conn, %{"id" => id, "pool" => pool_params}) do
    pool = Core.get_pool!(id)
    case Core.update_pool(pool, pool_params) do
      {:ok, pool} ->
        render conn, "show.html", pool: pool

      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, pool: pool
    end
  end
end
