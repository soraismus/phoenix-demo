defmodule AssessmentWeb.Api.OrderController do
  use AssessmentWeb, :controller
  import Assessment.Utilities, only: [error_data: 1]
  alias Assessment.Orders

  action_fallback(AssessmentWeb.Api.ErrorController)

  @active "active"
  @canceled "canceled"
  @delivered "delivered"
  @undeliverable "undeliverable"

  def cancel(conn, %{"id" => id} = params) do
    update_order_state(conn, params, @canceled, "cancel.json")
  end

  defp check_elibility(order, order_state_description) do
    cond do
      order.order_state_description == order_state_description ->
        {:error, :already_has_order_state}
      order.order_state_description == @canceled ->
        {:error, :already_canceled}
      order.order_state_description == @delivered ->
        {:error, :already_delivered}
      true ->
        {:ok, {order, order_state_description}}
    end
  end

  def create(conn, %{"order" => params}) do
    with {:ok, order} <- Orders.create_order(params) do
      conn
      |> put_status(:created)
      |> render("create.json", order: order)
    end
  end

  def deliver(conn, %{"id" => id} = params) do
    update_order_state(conn, params, @delivered, "deliver.json")
  end

  def index(conn, _params) do
    orders = Orders.list_orders(%{})
    conn |> render("index.json", orders: orders)
  end

  def mark_undeliverable(conn, %{"id" => id} = params) do
    update_order_state(conn, params, @undeliverable, "mark_undeliverable.json")
  end

  def show(conn, %{"id" => id}) do
    data = %{resource: "order ##{id}"}
    with {:ok, order} <- Orders.get_order(id) |> error_data(data).() do
      conn
      |> render("show.json", order: order)
    end
  end

  defp update_order_state(conn, %{"id" => id}, order_state_description, view) do
    data = %{resource: "order ##{id}", description: order_state_description}
    with {:ok, order} <- Orders.get_order(id) |> error_data(data).(),
         {:ok, _} <- check_elibility(order, @canceled) |> error_data(data).(),
         {:ok, new_order} <- Orders.update_order_state(order, order_state_description) do
      conn
      |> render(view, order: new_order)
    end
  end
end
