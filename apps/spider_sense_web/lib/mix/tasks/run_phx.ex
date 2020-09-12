defmodule Mix.Tasks.RunPhx do
  use Mix.Task

  def run(args \\ []) do
    #TODO
    #Application.env

    # set path to mix file from phx
    # use the mix file path from phx
    # subscribe phx liveview to the dexplorer
    # start the dexplorer
    Mix.Task.run("phx.server", ["--no-mix-exs", "--no-halt"])
  end
end
