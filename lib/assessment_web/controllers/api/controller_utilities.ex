defmodule AssessmentWeb.Api.ControllerUtilities do
  use AssessmentWeb, :controller
  alias Ecto.Changeset

  def authentication_error(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{errors: %{request: ["Authentication is required"]}})
  end

  def authorization_error(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{errors: %{request: ["Not Authorized"]}})
  end

  def changeset_error(conn, %Changeset{} = changeset, status \\ 400) do
    conn
    |> put_status(status)
    |> json(%{errors: translate_errors(changeset)})
  end

  def internal_error(conn, code) do
    conn
    |> resource_error("Internal Error", "Code: #{code}", 500)
  end

  def resource_error(conn, resource, msg, status \\ 400) do
    conn
    |> put_status(status)
    |> json(%{errors: %{resource => [msg]}})
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
