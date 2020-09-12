defmodule SpiderSenseWeb.CLI do
  def main(_args) do
    Application.ensure_all_started(:spider_sense_web)
    Mix.Task.run("phx.server", ["--no-mix-exs", "--no-halt"])
    Process.sleep(1000000)
  end
end
