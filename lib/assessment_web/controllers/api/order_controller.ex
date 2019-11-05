defmodule AssessmentWeb.Api.OrderController do
  use AssessmentWeb, :controller
  alias Assessment.Orders

  action_fallback(AssessmentWeb.Api.ErrorController)

  def create(conn, %{"order" => params}) do
    # pickup_date pickup_time patient_id pharmacy_id order_state_id courier_id
    with {:ok, order} <- Orders.create_order(params) do
      conn
      |> put_status(:created)
      |> render("create.json", order: order)
    end
  end

  def index(conn, _params) do
    orders = Orders.list_orders(%{})
    conn |> render("index.json", orders: orders)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, order} <- Orders.get_order(id) do
      conn
      |> render("show.json", order: order)
    end
  end
end
