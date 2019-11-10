defmodule AssessmentWeb.AuthErrorHandler do
  use AssessmentWeb, :controller

  def auth_error(%Plug.Conn{} = conn, {_type, _reason}, _opts) do
    note = "(Consider resetting Guardian's 'ttl' value in 'config.ex'.)"
    msg = "Expired credentials #{note}"
    conn
    |> AssessmentWeb.Guardian.Plug.sign_out()
    |> clear_session()
    |> put_flash(:warning, msg)
    |> redirect(to: session_path(conn, :create))
  end
end
