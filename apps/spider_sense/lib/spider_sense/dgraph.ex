defmodule SpiderSense.DGraph do
  @doc """
  A struct which collects nodes and links from Tracer
  and can be used as a state in consumers which render a deps tree
  """
  @ignore_modules [
    :compile,
    :elixir_def,
    :elixir_module,
    :elixir_utils,
    nil
  ]

  defstruct nodes: %{},
            links: %{}

  defmodule Node, do: defstruct(~w(name meta)a)
  defmodule Link, do: defstruct(~w(source sink meta)a)
  defmodule NodeMeta, do: defstruct(~w(belongs_to_project?)a)
  defmodule LinkMeta, do: defstruct(~w()a)

  import Access, only: [key!: 1]

  def put_node(%__MODULE__{} = graph, name, meta) do
    put_in(graph, [key!(:nodes), name], %Node{name: name, meta: meta})
  end

  def put_new_node(%__MODULE__{} = graph, name, meta) do
    if Map.has_key?(graph.nodes, name) ||
         Enum.member?(@ignore_modules, name) do
      graph
    else
      put_node(graph, name, meta)
    end
  end

  def put_link(%__MODULE__{} = graph, source, sink, meta) do
    link_name = get_link_name(source, sink)

    graph
    |> put_new_node(source, %NodeMeta{belongs_to_project?: false})
    |> put_new_node(sink, %NodeMeta{belongs_to_project?: false})
    |> put_in([key!(:links), link_name], %Link{source: source, sink: sink, meta: meta})
  end

  def process_event(%__MODULE__{} = graph, event) do
    case event do
      {:explorer, {:remote_function, _, :elixir_module, :compile, _}, env} ->
        env.context_modules
        |> Enum.reduce(graph, fn module, graph ->
          put_node(graph, module, %NodeMeta{belongs_to_project?: true})
        end)
        |> put_link(:elixir_module, :compile, %LinkMeta{})

      {:explorer, {:remote_function, _, module_name, _function_name, _}, %{module: caller_module}} ->
        put_link(graph, caller_module, module_name, %LinkMeta{})

      _ ->
        graph
    end
  end

  def list_nodes(%__MODULE__{} = graph), do: Map.values(graph.nodes)
  def list_links(%__MODULE__{} = graph), do: Map.values(graph.links)

  def filter_by(%__MODULE__{} = full_graph, params) do
    Enum.reduce(params, full_graph, fn
      {:is_external_modules_hidden, true}, graph ->
        project_nodes =
          graph.nodes
          |> Enum.filter(fn
            {_, %{meta: %{belongs_to_project?: true}}} -> true
            _ -> false
          end)
          |> Map.new()

        put_in(graph, [key!(:nodes)], project_nodes)

      {:checked_modules, modules}, graph ->
        project_nodes =
          graph.nodes
          |> Enum.filter(fn {_, %{name: name}} -> name in modules end)
          |> Map.new()

        put_in(graph, [key!(:nodes)], project_nodes)

      _, graph ->
        graph
    end)
    |> filter_links_not_listed_in_modules()
  end

  defp filter_links_not_listed_in_modules(graph) do
    project_modules_names = Map.keys(graph.nodes)

    project_links =
      graph.links
      |> Enum.filter(fn
        {_, %{source: source, sink: sink}} ->
          source in project_modules_names and sink in project_modules_names

        _ ->
          false
      end)
      |> Map.new()

    put_in(graph, [key!(:links)], project_links)
  end

  defp get_link_name(source, sink), do: to_string(source) <> "--" <> to_string(sink)
end
