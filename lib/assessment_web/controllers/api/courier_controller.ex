defmodule AssessmentWeb.Api.CourierController do
  use AssessmentWeb, :controller
  import Assessment.Utilities, only: [error_data: 1]
  alias Assessment.Accounts

  action_fallback(AssessmentWeb.Api.ErrorController)

  def create(conn, %{"courier" => params}) do
    params =
      %{}
      |> Map.put("username", Map.get(params, "username"))
      |> Map.put("credential", Map.take(params, ["password"]))
      |> Map.put("courier", Map.take(params, ["name", "email", "address"]))
    with {:ok, agent} <- Accounts.create_courier(params) do
      conn
      |> put_status(:created)
      |> render("create.json", courier: agent.courier)
    end
  end

  def index(conn, _params) do
    couriers = Accounts.list_couriers()
    conn
    |> render("index.json", couriers: couriers)
  end

  def show(conn, %{"id" => id}) do
    data = %{resource: "courier ##{id}"}
    with {:ok, courier} <- Accounts.get_courier(id) |> error_data(data).() do
      conn
      |> render("show.json", courier: courier)
    end
  end
end
