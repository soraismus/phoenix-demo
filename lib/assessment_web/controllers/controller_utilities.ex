defmodule AssessmentWeb.ControllerUtilities do
  use AssessmentWeb, :controller
  alias Ecto.Changeset

  def authentication_error(conn, msg \\ "Not authorized") do
    conn
    |> put_status(:unauthorized)
    |> put_flash(:error, msg)
    |> redirect(to: page_path(conn, :index))
  end

  def authorization_error(conn, msg \\ "Not Authorized") do
    conn
    |> put_status(:unauthorized)
    |> put_flash(:error, msg)
    |> redirect(to: page_path(conn, :index))
  end

  def changeset_error(
    conn,
    view: view,
    order: order,
    changeset: %Changeset{} = changeset,
    status: status) do
        status = if is_nil(status), do: 400, else: status
        conn
        |> put_status(status)
        |> render(view, changeset: changeset, order: order)
  end

  def internal_error(conn, code) do
    conn
    |> put_status(500)
    |> put_flash(:error, "Internal Error -- Code: #{code}")
    |> render(to: page_path(conn, :index))
  end
end
