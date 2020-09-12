defmodule SpiderSenseWeb.FiltersLive do
  @moduledoc """
  LiveView component used for filtering the list of modules
  and selecting which modules to display in the graph.
  """
  use Phoenix.LiveView

  # Usages of this should be replaced with the Modules
  # so that they appear in the filterable datalist.
  @test_matches [
    "alpha",
    "beta",
    "gamma",
    "delta",
    "epsilon"
  ]

  @impl Phoenix.LiveView
  def render(assigns) do
    ~L"""
    <form phx-change="filter">
      <input name="filter" value="<%= @filter %>"
        list="matches">
      </input>
      <datalist id="matches">
        <%= for match <- @matches do %>
          <option value="<%= match %>"><%= match %></option>
        <% end %>
      </datalist>
      <input type="submit" />
    </form>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket = socket
      |> assign(:filter, "")
      |> assign(:matches, [])

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("filter", %{"filter" => filter}, socket) do
    results = @test_matches
      |> Enum.filter(fn x -> String.contains?(x, filter) end)

    socket = socket
      |> assign(:matches, results)

    {:noreply, socket}
  end
end