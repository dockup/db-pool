defmodule DbPool do
  @moduledoc """
  DbPool keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def init() do
    DbPool.Config.set_configs_from_env()
  end
end
