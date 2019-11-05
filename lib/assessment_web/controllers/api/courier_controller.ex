defmodule AssessmentWeb.Api.CourierController do
  use AssessmentWeb, :controller
  alias Assessment.Accounts

  def index(conn, _params) do
    couriers = Accounts.list_couriers()
    conn
    |> render("index.json", couriers: couriers)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, courier} <- Accounts.get_courier(id) do
      conn
      |> render("show.json", courier: courier)
    end
  end
end
