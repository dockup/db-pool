defmodule DbPool.Utils do
  alias DbPool.Core.Pool

  @postgres_envs ~w(PGHOST PGUSER PGPASSWORD)
  @mysql_envs ~w(MYSQL_HOST USER MYSQL_PWD)

  def get_envs(), do: get_envs(Application.fetch_env!(:db_pool, :pool))
  def get_envs(%Pool{} = pool) do
    values = [pool.host, pool.username, pool.password]
    get_envs(pool.adapter, values)
  end
  def get_envs("postgres", values), do: Enum.zip(@postgres_envs, values)
  def get_envs("mysql", values), do: Enum.zip(@mysql_envs, values)
end
