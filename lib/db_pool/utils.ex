defmodule DbPool.Utils do
  alias DbPool.Core.Pool

  def get_envs(%Pool{} = pool), do: get_envs(pool, pool.adapter)

  def get_envs(%Pool{} = pool, "postgres") do
    [
      {"PGHOST", pool.host},
      {"PGUSER", pool.username},
      {"PGPASSWORD", pool.password},
    ]
  end

  def get_envs(%Pool{} = pool, "mysql") do
    [
      {"MYSQL_HOST", pool.host},
      {"USER", pool.username},
      {"MYSQL_PWD", pool.password},
    ]
  end
end
