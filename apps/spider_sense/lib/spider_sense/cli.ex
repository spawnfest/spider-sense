defmodule SpiderSense.CLI do
  alias SpiderSense.DExplorer
  alias SpiderSense.DGraph

  def main(_args) do
    DExplorer.stream_events("mix.exs")
    |> Enum.reduce(%DGraph{}, fn event, graph ->
      DGraph.process_event(graph, event)
    end)
    |> DGraph.list_nodes()
    |> Enum.each(fn node ->
      IO.inspect(node)
    end)

    # TODO: 
  end
end
