defmodule AssessmentWeb.OrderController do
  use AssessmentWeb, :controller

  alias Assessment.Orders
  alias Assessment.Orders.Order

  @ok :ok
  @error :error

  plug :authorize_order_management

  def index(conn, _params) do
    orders = Orders.list_orders()
    render(conn, "index.html", orders: orders)
  end

  def new(conn, _params) do
    changeset = Orders.change_order(%Order{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"order" => order_params}) do
    case Orders.create_order(order_params) do
      {@ok, order} ->
        conn
        |> put_flash(:info, "Order created successfully.")
        |> redirect(to: order_path(conn, :show, order))
      {@error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    with {@ok, order} <- Orders.get_order(id) do
      render(conn, "show.html", order: order)
    end
  end

  def edit(conn, %{"id" => id}) do
    with {@ok, order} <- Orders.get_order(id) do
      changeset = Orders.change_order(order)
      render(conn, "edit.html", order: order, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "order" => order_params}) do
    with {@ok, order} <- Orders.get_order(id) do
      case Orders.update_order(order, order_params) do
        {@ok, order} ->
          conn
          |> put_flash(:info, "Order updated successfully.")
          |> redirect(to: order_path(conn, :show, order))
        {@error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", order: order, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with {@ok, order} <- Orders.get_order(id),
         {@ok, _order} = Orders.delete_order(order) do
      conn
      |> put_flash(:info, "Order deleted successfully.")
      |> redirect(to: order_path(conn, :index))
    end
  end

  defp authorize_order_management(conn, _) do
    if conn.assigns.logged_in? do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to manage orders.")
      |> put_session(:request_path, conn.request_path)
      |> redirect(to: session_path(conn, :new))
      |> halt()
    end
  end
end
