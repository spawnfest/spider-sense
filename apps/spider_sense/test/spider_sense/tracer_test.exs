defmodule SpiderSense.TracerTest do
  use ExUnit.Case

  alias SpiderSense.Tracer

  test "&subscribe_events/1 should forward messages to subscriber" do
    Tracer.subscribe_events()
    Tracer.trace(:first_arg, :second_arg)
    assert_receive {:tracer, :first_arg, :second_arg}
  end
end
