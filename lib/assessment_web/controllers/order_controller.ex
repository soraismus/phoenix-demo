defmodule AssessmentWeb.OrderController do
  use AssessmentWeb, :controller

  alias Assessment.Orders
  alias Assessment.Orders.Order

  @ok :ok
  @error :error

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
end










  #plug :require_existing_author
  #plug :authorize_page when action in [:edit, :update, :delete]

  #defp require_existing_author(conn, _) do
  #  author = CMS.ensure_author_exists(conn.assigns.current_user)
  #  assign(conn, :current_author, author)
  #end

  #defp authorize_page(conn, _) do
  #  page = CMS.get_page!(conn.params["id"])
  #  if conn.assigns.current_author.id == page.author_id do
  #    assign(conn, :page, page)
  #  else
  #    conn
  #    |> put_flash(:error, "You can't modify that page")
  #    |> redirect(to: Routes.cms_page_path(conn, :index))
  #    |> halt()
  #  end
  #end

  #def ensure_author_exists(%Accounts.User{} = user) do
  #  %Author{user_id: user.id}
  #  |> Ecto.Changeset.change()
  #  |> Ecto.Changeset.unique_constraint(:user_id)
  #  |> Repo.insert()
  #  |> handle_existing_author()
  #end
  #defp handle_existing_author({:ok, author}), do: author
  #defp handle_existing_author({:error, changeset}) do
  #  Repo.get_by!(Author, user_id: changeset.data.user_id)
  #end
