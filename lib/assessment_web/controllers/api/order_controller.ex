defmodule AssessmentWeb.Api.OrderController do
  use AssessmentWeb, :controller
  import Assessment.Utilities, only: [error_data: 1]
  alias Assessment.Orders

  action_fallback(AssessmentWeb.Api.ErrorController)

  def cancel(conn, %{"id" => id}) do
    data = %{resource: "order ##{id}"}
    with {:ok, order} <- Orders.get_order(id) |> error_data(data).(),
         {:ok, new_order} <- Orders.update_order_state(order, "canceled") do
      conn
      |> render("cancel.json", order: new_order)
    end
  end

  def create(conn, %{"order" => params}) do
    with {:ok, order} <- Orders.create_order(params) do
      conn
      |> put_status(:created)
      |> render("create.json", order: order)
    end
  end

  def deliver(conn, %{"id" => id}) do
    data = %{resource: "order ##{id}"}
    with {:ok, order} <- Orders.get_order(id) |> error_data(data).(),
         {:ok, new_order} <- Orders.update_order_state(order, "delivered") do
      conn
      |> render("deliver.json", order: new_order)
    end
  end

  def index(conn, _params) do
    orders = Orders.list_orders(%{})
    conn |> render("index.json", orders: orders)
  end

  def mark_undeliverable(conn, %{"id" => id}) do
    data = %{resource: "order ##{id}"}
    with {:ok, order} <- Orders.get_order(id) |> error_data(data).(),
         {:ok, new_order} <- Orders.update_order_state(order, "undeliverable") do
      conn
      |> render("mark_undeliverable.json", order: new_order)
    end
  end

  def show(conn, %{"id" => id}) do
    data = %{resource: "order ##{id}"}
    with {:ok, order} <- Orders.get_order(id) |> error_data(data).() do
      conn
      |> render("show.json", order: order)
    end
  end
end
