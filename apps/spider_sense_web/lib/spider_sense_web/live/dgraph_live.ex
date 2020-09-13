defmodule SpiderSenseWeb.DGraphLive do
  use Phoenix.LiveView

  alias SpiderSense.DGraph

  def render(assigns) do
    ~L"""
    <h3>Live value: <%= @counter %></h3>
    <form phx-submit="load_graph">
      <label for="path">Path to the <code>mix.exs</code> file</label>
      <input type="text" name="path"></input>
      <button type="submit">Load Graph</button>
    </form>
    <%= if @loading do %>
      <div>Loading...</div>
    <% end %>
    <div id="dgraph" data-chart="<%= Jason.encode!(@chart_data) %>">
      <svg width="600" height="600"></svg>
    </div>
    <script>
    // Since this script is loaded immediately, it must wait for app.js to be
    // loaded, which inserts the DGraph constant into window
    function wait() {
      if (typeof DGraph !== "undefined") {
        // Load the chart initially
        DGraph.update_chart("dgraph");

        // Update the DGraph chart whenever data changes
        new MutationObserver(function(mutations, observer) {
          DGraph.update_chart('dgraph');
        }).observe(document.getElementById('dgraph'), {attributes: true});
      }
      else {
        setTimeout(wait, 250);
      }
    }
    wait();
    </script>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("load_graph", %{"path" => path}, socket) do
    # TODO: load graph here

    # kick off the graph loading
    {:noreply,
     socket
     |> assign(:loading, true)}
  end

  def mount(_params, _session, socket) do
    # TODO: replace with subscribe
    graph = SpiderSense.build_graph("../spider_sense/priv/example/mix.exs")

    nodes =
      graph
      |> DGraph.list_nodes()
      |> Enum.reject(& is_nil(&1.name))
      |> Enum.map(fn %{name: module} ->
        %{id: module, group: 1}
      end)

    links =
      DGraph.list_links(graph)
      |> Enum.reject(& is_nil(&1.source))
      |> Enum.map(fn %{source: source, sink: sink} ->
        %{source: source, target: sink, value: 1}
      end)

    {:ok,
     socket
     |> assign(:loading, false)
     |> assign(:counter, 0)
     |> assign(:chart_data, %{
       nodes: nodes,
       links: links
     })}
  end

  def handle_info({:explorer, _, _}, socket) do
    # TODO: use this
    {:noreply, socket}
  end
end
