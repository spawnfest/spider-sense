defmodule SpiderSenseWeb.DGraphLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <h3>Live value: <%= @counter %></h3>
    """
  end

  def mount(_params, _session, socket) do
    SpiderSenseWeb.Counter.start_link(self())
    {:ok, assign(socket, :counter, 0)}
  end

  def handle_info(:inc, socket) do
    {:noreply, assign(socket, :counter, socket.assigns.counter + 1)}
  end
end

defmodule SpiderSenseWeb.Counter do
  def start_link(to_pid) do
    spawn(fn -> loop(to_pid) end)
  end

  defp loop(to_pid) do
    Process.sleep(1000)
    Process.send(to_pid, :inc, [:noconnect])
    loop(to_pid)
  end
end
