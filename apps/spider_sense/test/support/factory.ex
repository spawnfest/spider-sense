defmodule SpiderSense.Factory do
  import Hammox

  alias SpiderSense.EventBus

  # TODO: wrap in spawn to emulate real
  def stub_compiler_tracer_events() do
    TracerMock
    |> expect(:start, fn _, _ ->
      {:ok, bin} = File.read("test/fixtures/events.bin")
      events = :erlang.binary_to_term(bin)

      Enum.each(events, fn event ->
        EventBus.dispatch(SpiderSense.DExplorer, event)
      end)
    end)
  end
end
