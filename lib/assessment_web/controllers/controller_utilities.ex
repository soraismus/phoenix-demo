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
    |> render(view, changeset: changeset, order_id: Map.get(params, :order_id))
  end

  def internal_error(conn, code) do
    conn
    |> put_status(500)
    |> put_flash(:error, "Internal Error -- Code: #{code}")
    |> render(to: page_path(conn, :index))
  end

  def validation_error(conn, error_json, status \\ 400) do
    conn
    |> put_status(status)
    |> put_flash(:error, to_error_list(error_json))
    |> redirect(to: page_path(conn, :index))
  end

  defp to_error_list(%{} = map) do
    Enum.reduce(
      map,
      [],
      fn ({key, values}, list) ->
        prefix = String.capitalize(to_string(key)) <> " "
        list ++ Enum.map(values, fn (value) -> prefix <> value <> "." end)
      end)
  end
end
