# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :db_pool,
  ecto_repos: [DbPool.Repo]

# Configures the endpoint
config :db_pool, DbPoolWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9VQg0D+EKZozKukeWHsxEtsHRIuhJya1TkVhKksROVKjjJD8yFagmTkQWe0XbkD8",
  render_errors: [view: DbPoolWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DbPool.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :db_pool, db_name: "dockup"
config :db_pool, db_adapter: "mysql"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
