defmodule AssessmentWeb.Api.PharmacyController do
  use AssessmentWeb, :controller
  alias Assessment.Accounts

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
