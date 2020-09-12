defmodule SpiderSense.MixProject do
  use Mix.Project

  def project do
    [
      app: :spider_sense,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "1.10.4",
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {SpiderSense.Application, []},
      extra_applications: [:logger, :mix]
    ]
  end

  def escript do
    [main_module: SpiderSense.CLI]
  end

  defp deps do
    []
  end
end
