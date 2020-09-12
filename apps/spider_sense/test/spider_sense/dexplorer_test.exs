defmodule SpiderSense.DExplorerTest do
  use ExUnit.Case

  alias SpiderSense.DExplorer

  @priv_dir :code.priv_dir(:spider_sense) |> to_string()
  @example_mix_exs @priv_dir <> "/example/mix.exs"

  test "&start/1 should start emit messages" do
    DExplorer.subscribe()
    DExplorer.start(@example_mix_exs)
    assert_receive {:explorer, :explore_project_start, _}, 1000
    assert_receive {:explorer, {:remote_function, _, _, _, _}, _}, 1000
    assert_receive {:explorer, :explore_project_end, _}, 1000
  end
end
