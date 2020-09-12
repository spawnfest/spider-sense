defmodule SpiderSense.DGraph do
  @doc """
  A struct which collects nodes and links from Tracer
  and can be used as a state in consumers which render a deps tree
  """

  defstruct nodes: %{},
            links: %{}

  defmodule Node, do: defstruct(~w(name meta)a)
  defmodule Link, do: defstruct(~w(source sink meta)a)

  import Access, only: [key!: 1]

  def put_node(%__MODULE__{} = graph, name, meta) do
    put_in(graph, [key!(:nodes), name], %Node{name: name, meta: meta})
  end

  def put_new_node(%__MODULE__{} = graph, name, meta) do
    if Map.has_key?(graph.nodes, name), do: graph, else: put_node(graph, name, meta)
  end

  def put_link(%__MODULE__{} = graph, source, sink, meta) do
    link_name = get_link_name(source, sink)

    graph
    |> put_new_node(source, nil)
    |> put_new_node(sink, nil)
    |> put_in([key!(:links), link_name], %Link{source: source, sink: sink, meta: meta})
  end

  def list_nodes(%__MODULE__{} = graph), do: Map.values(graph.nodes)
  def list_links(%__MODULE__{} = graph), do: Map.values(graph.links)

  defp get_link_name(source, sink), do: source <> "--" <> sink
end
