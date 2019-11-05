defmodule AssessmentWeb.PharmacyController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  plug :authenticate_administrator

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
      {:ok, %Agent{pharmacy: pharmacy}} ->
        conn
        |> put_flash(:info, "Pharmacy created successfully.")
        |> redirect(to: pharmacy_path(conn, :show, pharmacy))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, pharmacy} = Accounts.get_pharmacy(id) do
      render(conn, "show.html", pharmacy: pharmacy)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, pharmacy} = Accounts.get_pharmacy(id),
         {:ok, _} = Accounts.delete_pharmacy(pharmacy) do
      conn
      |> put_flash(:info, "Pharmacy deleted successfully.")
      |> redirect(to: pharmacy_path(conn, :index))
    end
  end

  defp authenticate_administrator(conn, _) do
    agent = conn.assigns.agent
    if agent && agent.account_type == "administrator" do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in as an administrator to manage pharmacies.")
      |> put_session(:request_path, conn.request_path)
      |> redirect(to: session_path(conn, :new))
      |> halt()
    end
  end
end
