defmodule AssessmentWeb.Browser.PageControllerTest do
  use AssessmentWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    msg = Plug.HTML.html_escape("Welcome to Matthew Hilty's Phoenix demo!")
    assert html_response(conn, 200) =~ msg
  end
end
