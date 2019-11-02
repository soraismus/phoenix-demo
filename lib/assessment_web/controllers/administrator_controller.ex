defmodule AssessmentWeb.AdministratorController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts
  alias Assessment.Accounts.Administrator

  def index(conn, _params) do
    administrators = Accounts.list_administrators()
    render(conn, "index.html", administrators: administrators)
  end

  #def new(conn, _params) do
  #  changeset = Accounts.change_administrator(%Administrator{})
  #  render(conn, "new.html", changeset: changeset)
  #end
  def new(conn, _params) do
    changeset = Accounts.change_administrator()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"administrator" => administrator_params}) do
    case Accounts.create_administrator(administrator_params) do
      {:ok, administrator} ->
        conn
        |> put_flash(:info, "Administrator created successfully.")
        |> redirect(to: administrator_path(conn, :show, administrator))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    {:ok, administrator} = Accounts.get_administrator(id)
    render(conn, "show.html", administrator: administrator)
  end

  def delete(conn, %{"id" => id}) do
    {:ok, administrator} = Accounts.get_administrator(id)
    {:ok, _administrator} = Accounts.delete_administrator(administrator)

    conn
    |> put_flash(:info, "Administrator deleted successfully.")
    |> redirect(to: administrator_path(conn, :index))
  end
end
