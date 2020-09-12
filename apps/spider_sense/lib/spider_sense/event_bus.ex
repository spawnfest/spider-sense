defmodule SpiderSense.EventBus do
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {Registry, :start_link, [[keys: :duplicate, name: __MODULE__]]}
    }
  end

  def subscribe(key \\ nil) do
    Registry.register(__MODULE__, key, nil)
  end

  def dispatch(key \\ nil, message) do
    Registry.dispatch(__MODULE__, key, fn entries ->
      for {pid, _} <- entries, do: send(pid, message)
    end)
  end
end
