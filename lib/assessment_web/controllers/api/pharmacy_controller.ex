defmodule AssessmentWeb.Api.PharmacyController do
  use AssessmentWeb, :controller
  alias Assessment.Accounts

  action_fallback(AssessmentWeb.Api.ErrorController)

  def create(conn, %{"pharmacy" => params}) do
    params =
      %{}
      |> Map.put("username", Map.get(params, "username"))
      |> Map.put("credential", Map.take(params, ["password"]))
      |> Map.put("pharmacy", Map.take(params, ["name", "email", "address"]))
    with {:ok, agent} <- Accounts.create_pharmacy(params) do
      conn
      |> put_status(:created)
      |> render("create.json", pharmacy: agent.pharmacy)
    end
  end

  def index(conn, _params) do
    pharmacies = Accounts.list_pharmacies()
    conn
    |> render("index.json", pharmacies: pharmacies)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, pharmacy} <- Accounts.get_pharmacy(id) do
      conn
      |> render("show.json", pharmacy: pharmacy)
    end
  end
end
