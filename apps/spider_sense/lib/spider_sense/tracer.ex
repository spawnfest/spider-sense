defmodule SpiderSense.Tracer do
  @spec trace(tuple, Macro.Env.t()) :: :ok
  def trace(event, env) do
    # TODO:
    {event, env} |> IO.inspect
    :ok
  end

  def trace(_, _), do: :ok
end
