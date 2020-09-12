defmodule SpiderSenseWeb.DGraphLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <h3>Live value: <%= @counter %></h3>
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

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:counter, 0)
      |> assign(:chart_data, %{
        nodes: [
          %{id: "test1", group: 1},
          %{id: "test2", group: 1},
          %{id: "test3", group: 2}
        ],
        links: [
          %{source: "test1", target: "test2", value: 1},
          %{source: "test1", target: "test3", value: 1}
        ]
      })
    }
  end
end
