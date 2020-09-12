defmodule SpiderSense.Tracer do
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {Registry, :start_link, [[keys: :duplicate, name: __MODULE__]]}
    }
  end

  def trace(compiler_event, env) do
    tracer_event = build_tracer_event(compiler_event, env)
    dispatch_event(tracer_event)

    :ok
  end

  def subscribe_events() do
    Registry.register(__MODULE__, nil, nil)
  end

  def dispatch_event(message) do
    Registry.dispatch(__MODULE__, nil, fn entries ->
      for {pid, _} <- entries, do: send(pid, message)
    end)
  end

  def build_tracer_event(event, env), do: {:tracer, event, env}
end
