# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hw07,
  ecto_repos: [Hw07.Repo]

config :hw07, Hw07.Repo,
database: "hw07_app",
username: "hw07",
password: "Joi7Yo3A",
hostname: "localhost",
port: "5432"

# Configures the endpoint
config :hw07, Hw07Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "v3ModbIqrIq32v3Yf5LOvK0JToGMKUQ0eKf3RCuzkRemxhIVHmi2n3pJQW+Bus2J",
  render_errors: [view: Hw07Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Hw07.PubSub,
  live_view: [signing_salt: "ygmtB+AG"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
