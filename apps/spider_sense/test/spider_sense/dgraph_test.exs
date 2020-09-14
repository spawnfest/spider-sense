defmodule SpiderSense.DGraphTest do
  use ExUnit.Case

  alias SpiderSense.DGraph

  import SpiderSense.Factory

  test "&put_node/1" do
    state = %DGraph{}
    state = DGraph.put_node(state, "node_name1", :meta1)
    state = DGraph.put_node(state, "node_name2", :meta2)

    assert [
             %{name: "node_name1", meta: :meta1},
             %{name: "node_name2", meta: :meta2}
           ] = DGraph.list_nodes(state)
  end

  test "&put_node/1 overrides meta if same node name given" do
    state = %DGraph{}
    state = DGraph.put_node(state, "node_name1", :meta1)
    state = DGraph.put_node(state, "node_name1", :meta2)

    assert [
             %{name: "node_name1", meta: :meta2}
           ] = DGraph.list_nodes(state)
  end

  test "&put_link/1 creates missing nodes without meta" do
    state = %DGraph{}
    state = DGraph.put_node(state, "node_name2", :node_meta1)
    state = DGraph.put_link(state, "node_name1", "node_name2", :meta1)
    state = DGraph.put_link(state, "node_name1", "node_name3", :meta2)

    assert [
             %{source: "node_name1", sink: "node_name2", meta: :meta1},
             %{source: "node_name1", sink: "node_name3", meta: :meta2}
           ] = DGraph.list_links(state)

    assert [
             %{name: "node_name1", meta: %{belongs_to_project?: false}},
             %{name: "node_name2", meta: :node_meta1},
             %{name: "node_name3", meta: %{belongs_to_project?: false}}
           ] = DGraph.list_nodes(state)
  end

  test "&process_event/2 should process all events" do
    full_graph =
      Enum.reduce(generate_events(), %DGraph{}, fn event, graph ->
        DGraph.process_event(graph, event)
      end)

    nodes = DGraph.list_nodes(full_graph)
    links = DGraph.list_links(full_graph)

    assert length(nodes) == 26
    assert length(links) == 66

    assert %{meta: %{belongs_to_project?: true}} = Enum.find(nodes, &(&1.name == SpiderSense))
  end
end
