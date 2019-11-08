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

  def changeset_error(conn, %{view: view, changeset: %Changeset{} = changeset} = params) do
    conn
    |> put_status(Map.get(params, :status, 400))
    |> render(view, changeset: changeset, order: Map.get(params, :order))
  end

  def internal_error(conn, code) do
    conn
    |> put_status(500)
    |> put_flash(:error, "Internal Error -- Code: #{code}")
    |> render(to: page_path(conn, :index))
  end
end
