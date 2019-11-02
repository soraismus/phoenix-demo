defmodule AssessmentWeb.PharmacyController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  @ok :ok
  @error :error

  def index(conn, _params) do
    pharmacies = Accounts.list_pharmacies()
    render(conn, "index.html", pharmacies: pharmacies)
  end

  def new(conn, _params) do
    changeset = Accounts.change_pharmacy()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"agent" => agent_params}) do
    case Accounts.create_pharmacy(agent_params) do
      {@ok, %Agent{pharmacy: pharmacy}} ->
        conn
        |> put_flash(:info, "Pharmacy created successfully.")
        |> redirect(to: pharmacy_path(conn, :show, pharmacy))
      {@error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    {@ok, pharmacy} = Accounts.get_pharmacy(id)
    render(conn, "show.html", pharmacy: pharmacy)
  end

  def delete(conn, %{"id" => id}) do
    with {@ok, pharmacy} = Accounts.get_pharmacy(id),
         {@ok, _} = Accounts.delete_pharmacy(pharmacy) do
      conn
      |> put_flash(:info, "Pharmacy deleted successfully.")
      |> redirect(to: pharmacy_path(conn, :index))
    end
  end
end
