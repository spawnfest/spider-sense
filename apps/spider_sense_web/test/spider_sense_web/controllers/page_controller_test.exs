defmodule SpiderSenseWeb.PageControllerTest do
  use SpiderSenseWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to SpiderSense!"
  end
end
