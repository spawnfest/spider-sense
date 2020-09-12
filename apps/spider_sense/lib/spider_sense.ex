defmodule SpiderSense do
  @moduledoc """
  Documentation for `SpiderSense`.
  """

  @doc """
  Starts feeding the tracer with compilation events. It forcefully recompiles a mix project.
  """
  def start_collecting_project_info do
    Mix.Task.clear()
    Mix.Task.run("run", ["--no-mix-exs", "./mix.exs"])
    Mix.Task.run("compile", ["--force", "--tracer", SpiderSense.Tracer])
  end
end
