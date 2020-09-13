defmodule SpiderSenseWeb.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    Vapor.load!([%Vapor.Provider.Dotenv{}])
    load_system_env()

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(SpiderSenseWeb.Endpoint, []),
      # Start Phoenix PubSub
      {Phoenix.PubSub, [name: SpiderSenseWeb.PubSub, adapter: Phoenix.PubSub.PG2]}
      # Start your own worker by calling: SpiderSenseWeb.Worker.start_link(arg1, arg2, arg3)
      # worker(SpiderSenseWeb.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SpiderSenseWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SpiderSenseWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Loads the necessary configuration from the .env file at the
  # project root
  defp load_system_env() do
    port =
      case System.get_env("PORT") do
        nil -> raise("Environment variable PORT must be set")
        value -> String.to_integer(value)
      end

    secret_key_base =
      case System.get_env("SECRET_KEY_BASE") do
        nil -> raise("Environment variable SECRET_KEY_BASE must be set")
        value -> value
      end

    signing_salt =
      case System.get_env("SIGNING_SALT") do
        nil -> raise("Environment variable SIGNING_SALT must be set")
        value -> value
      end

    Application.put_env(
      :spider_sense_web, 
      SpiderSenseWeb.Endpoint, 
      http: [port: port], 
      secret_key_base: secret_key_base,
      live_view: [signing_salt: signing_salt],
      pubsub_server: SpiderSenseWeb.PubSub)
  end
end
