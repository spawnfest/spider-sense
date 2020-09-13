defmodule SpiderSense.DExplorerTest do
  use ExUnit.Case

  alias SpiderSense.DExplorer

  import SpiderSense.Factory
  import Hammox

  @priv_dir :code.priv_dir(:spider_sense) |> to_string()
  @example_mix_exs @priv_dir <> "/example/mix.exs"

  setup [
    :stub_compiler_tracer_events,
    :verify_on_exit!
  ]

  test "&start/1 should start emit messages" do
    DExplorer.subscribe()
    DExplorer.start(@example_mix_exs)
    assert_receive {:explorer, :explore_project_start, _}, 1000
    assert_receive {:explorer, {:remote_function, _, _, _, _}, _}, 1000
    assert_receive {:explorer, :explore_project_end, _}, 1000
  end

  test "&stream_events/1 stream should return an array of events" do
    events =
      DExplorer.stream_events(@example_mix_exs)
      |> Enum.into([])

    assert [
             {:explorer, :start, _},
             {:explorer, {:imported_macro, [line: 1], Kernel, :defmodule, 2}, _},
             {:explorer, {:alias_reference, [line: 1], SpiderSense}, _}
           ] = events |> Enum.take(3)
  end
end
