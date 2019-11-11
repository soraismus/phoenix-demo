defmodule AssessmentWeb.ControllerUtilities do
  use AssessmentWeb, :controller

  alias Ecto.Changeset

  @error :error
  @index :index
  @order_id :order_id
  @request_path :request_path
  @status :status

  def authentication_error(conn, msg \\ "Not must log in") do
    conn
    |> put_flash(@error, msg)
    |> put_session(@request_path, conn.request_path)
    |> redirect(to: session_path(conn, @new))
  end

  def authorization_error(conn, msg \\ "Not Authorized") do
    conn
    |> put_flash(@error, msg)
    |> redirect(to: page_path(conn, @index))
  end

  def changeset_error(conn, %{view: view, changeset: %Changeset{} = changeset} = params) do
    conn
    |> put_status(Map.get(params, @status, 400))
    |> render(view, changeset: changeset, order_id: Map.get(params, @order_id))
  end

  def internal_error(conn, code) do
    conn
    |> put_status(500)
    |> put_flash(@error, "Internal Error -- Code: #{code}")
    |> render(to: page_path(conn, @index))
  end

  def resource_error(conn, resource, msg) do
    conn
    |> put_flash(@error, "#{String.capitalize(resource)} #{msg}")
    |> redirect(to: page_path(conn, @index))
  end

  def validation_error(conn, error_json) do
    conn
    |> put_flash(@error, to_error_list(error_json))
    |> redirect(to: page_path(conn, @index))
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
