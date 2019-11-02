defmodule AssessmentWeb.SessionController do
  use AssessmentWeb, :controller

  #plug(
  #  Guardian.Plug.Pipeline,
  #  error_handler: AssessmentWeb.SessionController,
  #  module: AssessmentWeb.Guardian
  #)
  #plug(Guardian.Plug.VerifyHeader, realm: "Token")
  #plug(Guardian.Plug.LoadResource, allow_blank: true)

  def new(conn, _params) do
    render(conn, "new.html", conn: conn)
  end

  def create(conn, _params) do
    text(conn, "create session")
  end

  def delete(conn, _params) do
    text(conn, "delete session")
  end
end
