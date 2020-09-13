defmodule SpiderSenseWeb.Mixfile do
  use Mix.Project

  def project do
    [
      app: :spider_sense_web,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SpiderSenseWeb.Application, []},
      extra_applications: [:logger, :runtime_tools, :mix]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def escript do
    [main_module: SpiderSenseWeb.CLI]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:spider_sense, in_umbrella: true},
      {:phoenix, "~> 1.5"},
      {:phoenix_pubsub, "2.0.0"},
      {:phoenix_html, "2.14.2"},
      {:phoenix_live_reload, "1.2.4", only: :dev},
      {:gettext, "0.18.1"},
      {:plug_cowboy, "2.3.0"},
      {:jason, "1.2.2"},
      {:phoenix_live_view, "0.14.4"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    []
  end
end
