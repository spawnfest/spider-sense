# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :spider_sense_web,
  namespace: SpiderSenseWeb,
  ecto_repos: [SpiderSenseWeb.Repo]

# Configures the endpoint
config :spider_sense_web, SpiderSenseWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zEiS+Tc5AX7tjzS61vJ78YKURKROMIeK8JJ42LSTemMcQ3OxeOHXjtU56kCmRW0Q",
  render_errors: [view: SpiderSenseWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SpiderSenseWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :spider_sense_web, :generators,
  context_app: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
