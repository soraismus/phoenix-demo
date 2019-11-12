defmodule AssessmentWeb.Browser.PageControllerTest do
  use AssessmentWeb.ConnCase

  test "GET /", %{conn: conn} do
    response = get conn, "/"
    msg = Plug.HTML.html_escape("Welcome to Matthew Hilty's Phoenix demo!")
    assert html_response(response, 200) =~ msg
  end
end
