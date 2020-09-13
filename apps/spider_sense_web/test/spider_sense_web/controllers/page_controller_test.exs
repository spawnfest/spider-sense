defmodule SpiderSenseWeb.PageControllerTest do
  use SpiderSenseWeb.ConnCase

  import SpiderSense.Factory

  setup [
    :stub_compiler_tracer_events
  ]

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to SpiderSense!"
  end
end
