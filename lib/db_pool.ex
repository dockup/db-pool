defmodule DbPool do
  @moduledoc """
  DbPool keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  @supported_adapters ~w(postgres mysql)

  def init() do
    DbPool.Config.set_configs_from_env()
    validate_db_adapter()
  end

  defp validate_db_adapter() do
    db_adapter = Application.get_env(:db_pool, :db_adapter)
    unless db_adapter in @supported_adapters, do:
      raise "[!] Invalid Database Adapter."
  end
end
