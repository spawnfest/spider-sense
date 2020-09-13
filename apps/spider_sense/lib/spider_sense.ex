defmodule SpiderSense do
  @moduledoc """
  Documentation for `SpiderSense`.
  """

  alias SpiderSense.DExplorer
  alias SpiderSense.DGraph

  def build_graph(path_to_mix_file) do
    DExplorer.stream_events(path_to_mix_file)
    |> Enum.reduce(%DGraph{}, fn event, graph ->
      DGraph.process_event(graph, event)
    end)
  end
end
