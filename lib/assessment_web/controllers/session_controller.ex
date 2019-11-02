defmodule AssessmentWeb.SessionController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  #plug(
  #  Guardian.Plug.Pipeline,
  #  error_handler: AssessmentWeb.SessionController,
  #  module: AssessmentWeb.Guardian
  #)
  #plug(Guardian.Plug.VerifyHeader, realm: "Token")
  #plug(Guardian.Plug.LoadResource, allow_blank: true)

  def new(conn, _params) do
    changeset = Accounts.change_agent()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"agent" => %{"username" => username}}) do
    case Accounts.get_agent_by_username(username) do
      {:ok, agent} ->
        conn
        |> put_flash(:info, "Administrator created successfully.")
        |> redirect(to: page_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
      {:error, :no_resource} ->
        render(conn, AssessmentWeb.PageView, "index.html")
    end
  end

  def delete(conn, _params) do
    text(conn, "delete session")
  end
end
