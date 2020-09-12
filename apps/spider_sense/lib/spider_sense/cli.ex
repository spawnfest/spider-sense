defmodule SpiderSense.CLI do
  def main(_args) do
    SpiderSense.start_collecting_project_info()
  end
end
