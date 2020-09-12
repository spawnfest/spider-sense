defmodule SpiderSense.CLI do
  alias SpiderSense.DExplorer

  def main(_args) do
    DExplorer.subscribe()
    DExplorer.start("mix.exs")

    # TODO: 
  end
end
