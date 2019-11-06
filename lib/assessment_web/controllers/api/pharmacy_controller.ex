defmodule AssessmentWeb.Api.PharmacyController do
  use AssessmentWeb, :controller
  import AssessmentWeb.Api.ControllerUtilities,
    only: [changeset_error: 2, internal_error: 2, resource_error: 4]
  alias Assessment.Accounts

  def create(conn, %{"pharmacy" => params}) do
    params =
      %{}
      |> Map.put("username", Map.get(params, "username"))
      |> Map.put("credential", Map.take(params, ["password"]))
      |> Map.put("pharmacy", Map.take(params, ["name", "email", "address"]))
    case Accounts.create_pharmacy(params) do
      {:ok, agent} ->
        conn
        |> put_status(:created)
        |> render("create.json", pharmacy: agent.pharmacy)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("PHCR")
    end
  end

  def index(conn, _params) do
    conn
    |> render("index.json", pharmacies: Accounts.list_pharmacies())
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_pharmacy(id) do
      {:ok, pharmacy} ->
        conn
        |> render("show.json", pharmacy: pharmacy)
      {:error, :no_resource} ->
        conn
        |> resource_error("pharmacy ##{id}", "does not exist", :not_found)
      _ ->
        conn
        |> internal_error("PHSH")
    end
  end
end
