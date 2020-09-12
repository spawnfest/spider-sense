defmodule SpiderSense.Adapters do
  def tracer(), do: Application.get_env(:spider_sense, :tracer_adapter, Impl)
end
