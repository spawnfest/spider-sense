defmodule SpiderSenseWeb.CLI do
  alias SpiderSense.DGraph

  def main(["list" | args]) do
    path_to_mix_file = List.first(args) || "mix.exs"

    graph = SpiderSense.build_graph(path_to_mix_file)

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
    start_server()

    receive do
      after
      :infinity -> nil
    end
  end

  defp start_server() do
    Application.put_env(:phoenix, :serve_endpoints, true, persistent: true)
    Mix.Tasks.Run.run ["--no-mix-exs"]
  end
end
