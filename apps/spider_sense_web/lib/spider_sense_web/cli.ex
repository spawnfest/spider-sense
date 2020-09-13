defmodule SpiderSenseWeb.CLI do
  def main(_args) do
    receive do
      :exit -> nil
      after
      :infinity -> nil
    end
  end
end
