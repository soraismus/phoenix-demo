defmodule AssessmentWeb.Api.OrderController do
  use AssessmentWeb, :controller
  alias Assessment.Orders

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
