defmodule DbPool do
  @moduledoc """
  DbPool keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias DbPool.Core.Pool

  @supported_adapters ~w(postgres mysql)

  def init() do
    DbPool.Config.set_configs_from_env()
    validate_db_adapter()
    set_pool()
  end

  defp validate_db_adapter() do
    db_adapter = Application.get_env(:db_pool, :db_adapter)
    unless db_adapter in @supported_adapters, do:
      raise "[!] Invalid Database Adapter."
  end

  defp set_pool() do
    pool = %Pool{
      host: Application.fetch_env!(:db_pool, :db_host),
      username: Application.fetch_env!(:db_pool, :db_username),
      password: Application.get_env(:db_pool, :db_password),
      adapter:  Application.fetch_env!(:db_pool, :db_adapter),
      name_prefix:  Application.fetch_env!(:db_pool, :db_name_prefix),
      dump_url:  Application.fetch_env!(:db_pool, :db_dump_url)
    }
    Application.put_env(:db_pool, :pool, pool)
  end
end
