defmodule AssessmentWeb.PharmacyController do
  use AssessmentWeb, :controller

  import AssessmentWeb.ControllerUtilities,
    only: [ internal_error: 2,
            resource_error: 3,
          ]

  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  plug :authenticate_administrator

  def index(conn, _params) do
    conn
    |> render("index.html", pharmacies: Accounts.list_pharmacies())
  end

  def new(conn, _params) do
    conn
    |> render("new.html", changeset: Accounts.change_pharmacy())
  end

  def create(conn, %{"agent" => agent_params}) do
    case Accounts.create_pharmacy(agent_params) do
      {:ok, %Agent{pharmacy: pharmacy}} ->
        conn
        |> put_flash(:info, "Pharmacy created successfully.")
        |> redirect(to: pharmacy_path(conn, :show, pharmacy))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("new.html", changeset: changeset)
      _ ->
        conn
        |> internal_error("PHCR_B")
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, pharmacy} = Accounts.get_pharmacy(id) do
      conn
      |> render("show.html", pharmacy: pharmacy)
    else
      {@error, @no_resource} ->
        conn
        |> resource_error("pharmacy ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("PHSH_B")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, pharmacy} = Accounts.get_pharmacy(id),
         {:ok, _} = Accounts.delete_pharmacy(pharmacy) do
      conn
      |> put_flash(:info, "Pharmacy deleted successfully.")
      |> redirect(to: pharmacy_path(conn, :index))
    else
      {@error, @no_resource} ->
        conn
        |> resource_error("pharmacy ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("PHDE_B")
    end
  end

  defp authenticate_administrator(conn, _) do
    agent = conn.assigns.agent
    if agent && agent.account_type == "administrator" do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in as an administrator to manage pharmacies.")
      |> put_session(:request_path, :ignore)
      |> redirect(to: session_path(conn, :new))
      |> halt()
    end
  end
end
