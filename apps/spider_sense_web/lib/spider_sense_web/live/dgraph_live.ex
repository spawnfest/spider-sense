defmodule SpiderSenseWeb.DGraphLive do
  use Phoenix.LiveView

  alias SpiderSense.DExplorer
  alias SpiderSense.DGraph

  @impl Phoenix.LiveView
  def render(assigns) do
    ~L"""
    <h3>Live value: <%= @counter %></h3>
    <form phx-submit="load_graph">
      <label for="path">Path to the <code>mix.exs</code> file</label>
      <input type="text" name="mix_path" value="<%= @mix_path %>"></input>
      <button type="submit">Load Graph</button>
    </form>
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
     |> update_chart_data_by_dgraph()
    }
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    DExplorer.subscribe()
    mix_path = "../spider_sense/priv/example/mix.exs"
    DExplorer.start(mix_path)

    {:ok,
     socket
     |> assign(:loading, false)
     |> assign(:counter, 0)
     |> assign(:mix_path, mix_path)
     |> assign(:dgraph, %DGraph{})
     |> update_chart_data_by_dgraph()
    }
  end

  @impl Phoenix.LiveView
  def handle_info({:explorer, :explore_project_start, _}, socket) do
    {:noreply, assign(socket, :loading, true)}
  end

  def handle_info({:explorer, :explore_project_end, _}, socket) do
    {:noreply, assign(socket, :loading, false)}
  end

  def handle_info({:explorer, _, _} = event, socket) do
    socket =
      socket
      |> update_dgraph_by_event(event)
      |> update_chart_data_by_dgraph()

    {:noreply, socket}
  end

  defp update_dgraph_by_event(socket, event) do
    dgraph = DGraph.process_event(socket.assigns.dgraph, event)
    assign(socket, :dgraph, dgraph)
  end

  defp update_chart_data_by_dgraph(socket) do
    dgraph = socket.assigns.dgraph

    nodes =
      DGraph.list_nodes(dgraph)
      |> Enum.reject(& is_nil(&1.name))
      |> Enum.map(fn %{name: module} ->
        %{id: module, group: 1}
      end)

    links =
      DGraph.list_links(dgraph)
      |> Enum.reject(& is_nil(&1.source))
      |> Enum.map(fn %{source: source, sink: sink} ->
        %{source: source, target: sink, value: 1}
      end)

    socket
    |> assign(:chart_data, %{
      nodes: nodes,
      links: links
    })
  end
end
