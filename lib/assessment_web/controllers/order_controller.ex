defmodule AssessmentWeb.OrderController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts.{Agent,Administrator,Courier,Pharmacy}
  alias Assessment.Orders
  alias Assessment.Orders.Order
  alias AssessmentWeb.GuardianController

  plug :authorize_order_management

  action_fallback(AssessmentWeb.OrderController.ErrorController)

  def index(conn, _params) do
    orders = Orders.list_orders()
    render(conn, "index.html", orders: orders)
  end

  def new(conn, _params) do
    changeset = Orders.change_order(%Order{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"order" => order_params}) do
    with {:ok, account} <- get_account(conn) do
      case account do
        %Administrator{} ->
          with {:ok, order} <- Orders.create_order(order_params) do
            conn
            |> put_flash(:info, "Order created successfully.")
            |> redirect(to: order_path(conn, :show, order))
          end
        %Pharmacy{} ->
          with {:ok, order} <- Orders.create_order(order_params) do
            conn
            |> put_flash(:info, "Order created successfully.")
            |> redirect(to: order_path(conn, :show, order))
          end
        _ ->
          conn
          |> put_flash(:error, "Not authorized to create an order")
          |> redirect(to: page_path(conn, :index))
      end
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, order} <- Orders.get_order(id) do
      render(conn, "show.html", order: order)
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, order} <- Orders.get_order(id) do
      changeset = Orders.change_order(order)
      render(conn, "edit.html", order: order, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "order" => order_params}) do
    with {:ok, order} <- Orders.get_order(id) do
      case Orders.update_order(order, order_params) do
        {:ok, order} ->
          conn
          |> put_flash(:info, "Order updated successfully.")
          |> redirect(to: order_path(conn, :show, order))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", order: order, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, order} <- Orders.get_order(id),
         {:ok, _order} = Orders.delete_order(order) do
      conn
      |> put_flash(:info, "Order deleted successfully.")
      |> redirect(to: order_path(conn, :index))
    end
  end

  defp authorize_order_management(conn, _) do
    if conn.assigns.agent do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to manage orders.")
      |> put_session(:request_path, conn.request_path)
      |> redirect(to: session_path(conn, :new))
      |> halt()
    end
  end

  defp authenticate_administrator(conn) do
    GuardianController.identify_administrator(conn.assigns.agent)
  end

  defp get_account(%Agent{} = agent) do
    case agent.account_type do
      "administrator" -> {:ok, agent.administrator}
      "courier"       -> {:ok, agent.courier}
      "pharmacy"      -> {:ok, agent.pharmacy}
      _               -> {:error, :invalid_account_type}
    end
  end
  defp get_account(%Plug.Conn{} = conn) do
    case conn.assigns.agent do
      nil -> {:error, :not_authenticated}
      agent -> get_account(agent)
    end
  end

  defmodule ErrorController do
    use AssessmentWeb, :controller

    def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
      render(conn, "new.html", changeset: changeset)
    end

    def call(conn, {:error, :invalid_account_type}) do
      conn
      |> put_flash(:error, "Not authorized to create an order")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {:error, :not_authenticated}) do
      conn
      |> put_flash(:error, "Not authorized to create an order")
      |> redirect(to: page_path(conn, :index))
    end
  end
end
