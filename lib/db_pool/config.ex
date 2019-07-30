defmodule DbPool.Config do
  def set_configs_from_env do
    for {env_var, config_key, type} <- configs() do
      value = System.get_env(env_var)
      unless value, do: raise "[!] You need to provide #{env_var}"
      set_config(System.get_env(env_var), config_key, type)
    end
  end

  defp configs do
    [
      {"DB_POOL_DB_DUMP_URL", :db_dump_url, :string},
      {"DB_POOL_DB_ADAPTER", :db_adapter, :string},
      {"DB_POOL_DB_NAME_PREFIX", :db_name_prefix, :string},
      {"DB_POOL_DB_HOST", :db_host, :string},
      {"DB_POOL_DB_USERNAME", :db_username, :string},
      {"DB_POOL_DB_PASSWORD", :db_password, :string}
    ]
  end

  defp set_config(nil, _, _) do
    # Do nothing if env var is not set
  end

  defp set_config("", _, _) do
    # Do nothing if env var is blank
  end

  defp set_config(env_val, config_key, :string) do
    Application.put_env(:db_pool, config_key, env_val)
  end
end
