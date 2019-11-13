defmodule AssessmentWeb.Api.ControllerUtilities do
  use AssessmentWeb, :controller

  alias Ecto.Changeset

  def authentication_error(conn, msg \\ "Authentication is required") do
    conn
    |> put_status(:unauthorized)
    |> json(%{errors: %{request: [msg]}})
  end

  def authorization_error(conn, msg \\ "Not Authorized") do
    conn
    |> put_status(:unauthorized)
    |> json(%{errors: %{request: [msg]}})
  end

  def changeset_error(conn, %Changeset{} = changeset, status \\ 400) do
    conn
    |> put_status(status)
    |> json(%{errors: translate_errors(changeset)})
  end

  def id_type_validation_error(conn, status \\ 400) do
    conn
    |> resource_error("id", "must be a positive integer", status)
  end

  def internal_error(conn, code) do
    conn
    |> resource_error("Internal Error", "Code: #{code}", 500)
  end

  def match_error(conn, purpose, status \\ 400) do
    conn
    |> resource_error(
          "Request #{purpose}",
          "has been given invalid data.",
          status)
  end

  def resource_error(conn, resource, msg, status \\ 400) do
    conn
    |> put_status(status)
    |> json(%{errors: %{resource => [msg]}})
  end

  def send_attachment(conn, content_type, filename, data) do
    conn
    |> put_resp_content_type(content_type)
    |> put_resp_header(
          "content-disposition",
          "attachment; filename=#{filename}")
    |> send_resp(200, data)
  end

  def validation_error(conn, error_json, status \\ 400) do
    conn
    |> put_status(status)
    |> json(%{errors: error_json})
  end

  defp translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(AssessmentWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(AssessmentWeb.Gettext, "errors", msg, opts)
    end
  end

  defp translate_errors(changeset) do
    Changeset.traverse_errors(changeset, &translate_error/1)
  end
end
