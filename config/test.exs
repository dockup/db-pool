use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :db_pool, DbPoolWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :db_pool, DbPool.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "db_pool_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
