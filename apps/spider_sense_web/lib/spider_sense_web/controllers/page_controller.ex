defmodule SpiderSenseWeb.PageController do
  use SpiderSenseWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
