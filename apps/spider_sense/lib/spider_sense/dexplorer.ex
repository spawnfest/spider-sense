defmodule SpiderSense.DExplorer do
  @moduledoc """
  Dependencies explorer uses `tracer` compilation flag to collect
  information about source code
  """

  alias SpiderSense.EventBus

  @doc """
  Starts feeding the tracer with compilation events.
  To receive these messages you must call `&subscribe/0`
  It forcefully recompiles a mix project.
  """
  def start(path_to_mix_file) do
    dispatch(:explore_project_start, nil)
    Mix.Task.clear()
    Mix.Task.run("run", ["--no-mix-exs", path_to_mix_file])
    Mix.Task.run("compile", ["--force", "--tracer", __MODULE__])
    dispatch(:explore_project_end, nil)
  end

  def subscribe() do
    EventBus.subscribe(__MODULE__)
  end

  @doc "Elixir compiler callback implementation"
  def trace(compiler_event, env) do
    dispatch(compiler_event, env)
    :ok
  end

  defp dispatch(compiler_event, env) do
    EventBus.dispatch(__MODULE__, {:explorer, compiler_event, env})
  end
end
