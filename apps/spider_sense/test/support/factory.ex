defmodule SpiderSense.Factory do
  import Hammox

  alias SpiderSense.EventBus

  # TODO: wrap in spawn to emulate real
  def stub_compiler_tracer_events(_) do
    TracerMock
    |> expect(:start, fn _, _ ->
      Enum.each(generate_events(), fn event ->
        EventBus.dispatch(SpiderSense.DExplorer, event)
      end)
    end)

    :ok
  end

  def generate_events() do
    {:ok, bin} = File.read("../spider_sense/test/fixtures/events.bin")
    :erlang.binary_to_term(bin)
  end
end
