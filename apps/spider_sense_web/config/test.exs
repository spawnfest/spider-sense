use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :spider_sense_web, SpiderSenseWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn
