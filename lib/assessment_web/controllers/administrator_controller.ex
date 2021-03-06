defmodule AssessmentWeb.AdministratorController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  @ok :ok
  @error :error

  def index(conn, _params) do
    administrators = Accounts.list_administrators()
    render(conn, "index.html", administrators: administrators)
  end

  def new(conn, _params) do
    changeset = Accounts.change_administrator()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"agent" => agent_params}) do
    case Accounts.create_administrator(agent_params) do
      {@ok, %Agent{administrator: administrator}} ->
        conn
        |> put_flash(:info, "Administrator created successfully.")
        |> redirect(to: administrator_path(conn, :show, administrator))
      {@error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    with {@ok, administrator} = Accounts.get_administrator(id) do
      render(conn, "show.html", administrator: administrator)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {@ok, administrator} = Accounts.get_administrator(id),
         {@ok, _} = Accounts.delete_administrator(administrator) do
      conn
      |> put_flash(:info, "Administrator deleted successfully.")
      |> redirect(to: administrator_path(conn, :index))
    end
  end
end
