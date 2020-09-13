defmodule Mix.Tasks.SpiderSense do
  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("hi there!")

    Mix.Task.run("phx.server", ["--no-mix-exs", "--no-halt"])
  end
end
