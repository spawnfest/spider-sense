defmodule SpiderSense.CLI do
  alias SpiderSense.DExplorer
  alias SpiderSense.DGraph

  def main(["list" | args]) do
    path_to_mix_file = List.first(args) || "mix.exs"

    graph =
      DExplorer.stream_events(path_to_mix_file)
      |> Enum.reduce(%DGraph{}, fn event, graph ->
        DGraph.process_event(graph, event)
      end)

    IO.puts("Modules: ")

    DGraph.list_nodes(graph)
    |> Enum.each(fn %{name: module} ->
      IO.puts("- " <> to_string(module))
    end)

    IO.puts("Links: ")

    DGraph.list_links(graph)
    |> Enum.each(fn %{source: source, sink: sink} ->
      IO.puts("- #{source} -> #{sink}")
    end)
  end

  def main(_args) do
  end
end
