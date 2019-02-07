defmodule DbPool.Core.Pool do
  defstruct host: nil,
    username: nil,
    password: nil,
    name_prefix: "db_pool_database_",
    adapter: nil,
    dump_url: nil,
    errored: false,
    error_message: ""
end
