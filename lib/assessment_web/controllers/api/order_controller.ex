defmodule AssessmentWeb.Api.OrderController do
  use AssessmentWeb, :controller
  import AssessmentWeb.Api.ControllerUtilities,
    only: [changeset_error: 3, internal_error: 1, resource_error: 3]
  alias Assessment.Orders

  @canceled "canceled"
  @delivered "delivered"
  @undeliverable "undeliverable"

  def cancel(conn, params) do
    conn
    |> update_order_state(params, @canceled, "cancel.json")
  end

  def create(conn, %{"order" => params}) do
    case Orders.create_order(params) do
      {:ok, order} ->
        conn
        |> put_status(:created)
        |> render("create.json", order: order)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("ORCR")
    end
  end

  def deliver(conn, params) do
    conn
    |> update_order_state(params, @delivered, "deliver.json")
  end

  def index(conn, _params) do
    conn
    |> render("index.json", orders: Orders.list_orders(%{}))
  end

  def mark_undeliverable(conn, params) do
    conn
    |> update_order_state(params, @undeliverable, "mark_undeliverable.json")
  end

  def show(conn, %{"id" => id}) do
    case Orders.get_order(id) do
      {:ok, order} ->
        conn
        |> render("show.json", order: order)
      {:error, :no_resource} ->
        conn
        |> resource_error("order ##{id}", "does not exist", :not_found)
      _ ->
        conn
        |> internal_error("ORSH")
    end
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

  defp update_order_state(conn, %{"id" => id}, description, view) do
    resource = "order ##{id}"
    with {:ok, order} <- Orders.get_order(id),
         {:ok, _} <- check_elibility(order, description),
         {:ok, new_order} <- Orders.update_order_state(order, description) do
      conn
      |> render(view, order: new_order)
    else
      {:error, :already_canceled} ->
        msg = "cannot be #{description} because it has already been canceled"
        conn
        |> resource_error(resource, msg)
      {:error, :already_delivered} ->
        msg = "cannot be #{description} because it has already been delivered"
        conn
        |> resource_error(resource, msg)
      {:error, :already_has_order_state} ->
        conn
        |> resource_error(resource, "is already #{description}")
      {:error, :no_resource} ->
        conn
        |> resource_error(resource, "does not exist", :not_found)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("ORUP")
    end
  end
end
