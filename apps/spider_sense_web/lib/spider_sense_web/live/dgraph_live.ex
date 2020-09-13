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
      <input type="text" name="mix_path" value="<%= @mix_path %>"></input>
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
          |> update_chart_data_by_dgraph()

        _ ->
          update_dgraph_by_event(socket, event)
      end

    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    IO.warn("Unhandled message: #{inspect msg}")
    {:noreply, socket}
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
end
