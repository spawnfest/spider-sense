defmodule SpiderSenseWeb.DGraphLive do
  use Phoenix.LiveView

  alias SpiderSense.DExplorer
  alias SpiderSense.DGraph

  import Phoenix.HTML.Form
  import Phoenix.HTML.Tag

  @impl Phoenix.LiveView
  def render(assigns) do
    ~L"""
    <form phx-submit="load_graph">
      <label for="path">Path to the <code>mix.exs</code> file</label>
      <input type="text" name="mix_path" value="<%= @mix_path %>"
        style="min-width: 300px;"></input>
      <button type="submit">Load Graph</button>
    </form>
    <%= form_for :filter, "/", [phx_change: "filter_changed"], fn _ -> %>
      <label>
        <%= tag(:input,
          name: "is_external_modules_hidden",
          type: "checkbox",
          checked: @is_external_modules_hidden) %>
        Show only project modules
      </label>
      <div class="container pre-scrollable">
        <%= for module <- @modules do %>
          <div class="row">
            <label>
              <%= tag(:input,
                name: "checked_modules[]",
                type: "checkbox",
                value: module,
                checked: module in @checked_modules) %>
              <%= module %>
            </label>
          </div>
        <% end %>
      </div>
    <% end %>
    <%= if @loading do %>
      <div>Loading...</div>
    <% end %>
    <div id="dgraph" phx-hook="DGraph" data-chart="<%= Jason.encode!(@chart_data) %>">
      <svg width="600" height="600"></svg>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("load_graph", %{"mix_path" => mix_path}, socket) do
    DExplorer.start(mix_path)

    {:noreply,
     socket
     |> assign(:mix_path, mix_path)
     |> assign(:dgraph, %DGraph{})
     |> update_chart_data_by_dgraph()}
  end

  @impl Phoenix.LiveView
  def handle_event("filter_changed", params, socket) do
    {:noreply,
     socket
     |> assign(:checked_modules, map_names_to_modules(params["checked_modules"]))
     |> assign(:is_external_modules_hidden, params["is_external_modules_hidden"] && true)
     |> update_chart_data_by_dgraph()}
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    DExplorer.subscribe()
    mix_path = "../spider_sense/priv/example/mix.exs"
    DExplorer.start(mix_path)

    {:ok,
     socket
     |> assign(:loading, false)
     |> assign(:is_external_modules_hidden, true)
     |> assign(:checked_modules, [])
     |> assign(:modules, [])
     |> assign(:mix_path, mix_path)
     |> assign(:dgraph, %DGraph{})
     |> update_chart_data_by_dgraph()}
  end

  @impl Phoenix.LiveView
  def handle_info({:explorer, compiler_event, _} = event, socket) do
    socket =
      case compiler_event do
        :explore_project_start ->
          socket
          |> assign(:loading, true)
          |> assign(:dgraph, %DGraph{})

        :explore_project_end ->
          socket
          |> assign(:loading, false)
          |> update_dgraph_by_event(event)
          |> init_modules_filter_state()
          |> update_chart_data_by_dgraph()

        _ ->
          update_dgraph_by_event(socket, event)
      end

    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    IO.warn("Unhandled message: #{inspect(msg)}")
    {:noreply, socket}
  end

  defp init_modules_filter_state(socket) do
    modules_names =
      socket.assigns.dgraph
      |> DGraph.list_nodes()
      |> Enum.map(& &1.name)

    socket
    |> assign(:checked_modules, modules_names)
    |> assign(:modules, modules_names)
  end

  defp update_dgraph_by_event(socket, event) do
    dgraph = DGraph.process_event(socket.assigns.dgraph, event)
    assign(socket, :dgraph, dgraph)
  end

  defp update_chart_data_by_dgraph(socket) do
    dgraph =
      socket.assigns.dgraph
      |> DGraph.filter_by(socket.assigns)

    nodes =
      DGraph.list_nodes(dgraph)
      |> Enum.reject(&is_nil(&1.name))
      |> Enum.map(fn %{name: module} ->
        %{id: module, group: 1}
      end)

    links =
      DGraph.list_links(dgraph)
      |> Enum.reject(&is_nil(&1.source))
      |> Enum.map(fn %{source: source, sink: sink} ->
        %{source: source, target: sink, value: 1}
      end)

    socket
    |> assign(:chart_data, %{
      nodes: nodes,
      links: links
    })
  end

  defp map_names_to_modules(names) do
    Enum.map(names, &String.to_existing_atom/1)
  rescue
    _ -> []
  end
end
