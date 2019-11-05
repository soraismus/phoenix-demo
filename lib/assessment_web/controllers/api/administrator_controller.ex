defmodule AssessmentWeb.Api.AdministratorController do
  use AssessmentWeb, :controller
  alias Assessment.Accounts

  def create(conn, %{"administrator" => administrator}) do
    case Accounts.create_administrator(agent_params) do
      {:ok, %Agent{administrator: administrator}} ->
        conn
        |> put_flash(:info, "Administrator created successfully.")
        |> redirect(to: administrator_path(conn, :show, administrator))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def index(conn, _params) do
    administrators = Accounts.list_administrators()
    conn
    |> render("index.json", administrators: administrators)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, administrator} <- Accounts.get_administrator(id) do
      conn
      |> render("show.json", administrator: administrator)
    end
  end
end
