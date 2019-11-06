defmodule AssessmentWeb.Api.ErrorController do
  use AssessmentWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> json(%{errors: translate_errors(changeset)})
  end

  def call(conn, {:error, :unauthenticated}) do
    conn
    |> resource_error(
          "login attempt",
          "invalid username/password combination",
          :unauthorized)
  end

  def call(conn, {:error, %{error: :already_canceled} = errors}) do
    resource = errors.resource
    description = errors.description
    msg = "cannot be #{description} because it has already been canceled"
    conn
    |> resource_error(resource, msg)
  end

  def call(conn, {:error, %{error: :already_delivered} = errors}) do
    description = errors.description
    msg = "cannot be #{description} because it has already been delivered"
    conn
    |> resource_error(errors.resource, msg)
  end

  def call(conn, {:error, %{error: :already_has_order_state} = errors}) do
    conn
    |> resource_error(errors.resource, "is already #{errors.description}")
  end

  def call(conn, {:error, %{error: :no_resource, resource: resource}}) do
    conn
    |> resource_error(resource, "does not exist", :not_found)
  end

  defp resource_error(conn, resource, msg, status \\ 400) do
    conn
    |> put_status(status)
    |> json(%{errors: %{resource => [msg]}})
  end

  defp translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext "errors", "is invalid"
    #
    #     # Translate the number of files with plural rules
    #     dngettext "errors", "1 file", "%{count} files", count
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(AssessmentWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(AssessmentWeb.Gettext, "errors", msg, opts)
    end
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end
end
