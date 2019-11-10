defmodule AssessmentWeb.OrderController do
  use AssessmentWeb, :controller

  import Assessment.Utilities, only: [accumulate_errors: 1, error_data: 1]
  import AssessmentWeb.ControllerUtilities,
    only: [ authentication_error: 2,
            authorization_error: 2,
            changeset_error: 2,
            internal_error: 2,
            validation_error: 2,
          ]
  import AssessmentWeb.GuardianController,
    only: [ authenticate_agent: 1,
            get_account: 1,
          ]
  import AssessmentWeb.OrderUtilities,
    only: [ normalize_edit_params: 2,
            normalize_validate_creation: 2,
            normalize_validate_index: 2,
          ]

  alias Assessment.Accounts
  alias Assessment.Accounts.{Administrator,Courier,Pharmacy}
  alias Assessment.Orders
  alias Assessment.Orders.Order
  alias AssessmentWeb.OrderView
  alias Ecto.Changeset

  plug :authenticate

  action_fallback(AssessmentWeb.OrderController.ErrorController)

  @created :created
  @error :error
  @ok :ok
  @not_authenticated :not_authenticated
  @not_authorized :not_authorized

  def create(conn, %{"order" => params}) do
    with {@ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         validated_params <- normalize_validate_creation(params, account),
         {@ok, normalized_params} <- accumulate_errors(validated_params),
         {@ok, order} <- Orders.create_order(normalized_params) do
      conn
      |> put_status(@created)
      |> put_flash(:info, "Order created successfully.")
      |> redirect(to: order_path(conn, :show, order))
    else
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Not authorized to create an order")
      {@error, @not_authorized} ->
        conn
        |> authorization_error("Not authorized to create an order")
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(%{view: "new.html", changeset: changeset})
      {@error, %{errors: _, valid_results: _} = partition} ->
        conn
        |> changeset_error(%{
                view: "new.html",
                changeset: OrderView.format_creation_errors(partition)
              })
      _ ->
        conn
        |> internal_error("ORCR")
    end
  end

  def index(conn, params) do
    with {@ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         validated_params <- normalize_validate_index(params, account),
         {@ok, normalized_params} <- accumulate_errors(validated_params) do
      conn
      |> assign(:normalized_params, normalized_params)
      |> render("index.html", orders: Orders.list_orders(normalized_params))
    else
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Not authorized to view orders")
      {@error, @not_authorized} ->
        conn
        |> authentication_error("Not authorized to view orders")
      {@error, %{errors: errors}} ->
        conn
        |> validation_error(OrderView.format_index_errors(errors))
      _ ->
        conn
        |> internal_error("ORIN")
    end
  end

  def new(conn, _params) do
    changeset = Orders.change_order(%Order{})
    render(conn, "new.html", changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    data = %{msg: "Invalid order id"}
    with {@ok, account} <- get_account(conn),
         {@ok, order} <- Orders.get_order(id) |> error_data(data).(),
         {@ok, _} <- authorize(account, order, "Not authorized to view order") do
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
    data = %{msg: "Invalid order id", view: "edit.html"}
    with {@ok, account} <- get_account(conn),
         {@ok, order} <- Orders.get_order(id) |> error_data(data).(),
         {@ok, _} <- authorize(account, order, "Not authorized to view order"),
         {@ok, new_params} <- normalize_edit_params(order_params, account),
         data <- Map.put(data, :order, order),
         {@ok, _} <- Orders.update_order(order, new_params) |> error_data(data).() do
      conn
      |> put_flash(:info, "Order updated successfully.")
      |> redirect(to: order_path(conn, :show, order))
    end
  end

  def delete(conn, %{"id" => id}) do
    data = %{msg: "Invalid order id"}
    with {@ok, account} <- get_account(conn),
         {@ok, order} <- Orders.get_order(id) |> error_data(data).(),
         {@ok, _} <- authorize(account, order, "Not authorized to delete order"),
         {@ok, _} <- Orders.delete_order(order) do
      conn
      |> put_flash(:info, "Order deleted successfully.")
      |> redirect(to: order_path(conn, :index))
    end
  end

  defp authorize(account, order, msg) do
    authorized? = case account do
      %Administrator{} -> true
      %Courier{} -> account.id == order.courier_id
      %Pharmacy{} -> account.id == order.pharmacy_id
    end
    if authorized? do
      {@ok, account}
    else
      {@error, %{error: @not_authorized, msg: msg}}
    end
  end

  defp authenticate(conn, _) do
    if conn.assigns.agent do
      conn
    else
      conn
      |> put_flash(@error, "You must be logged in to manage orders.")
      |> put_session(:request_path, conn.request_path)
      |> redirect(to: session_path(conn, :new))
      |> halt()
    end
  end

  defmodule ErrorController do
    use AssessmentWeb, :controller

    @error :error
    @not_authenticated :not_authenticated
    @not_authorized :not_authorized

    def call(conn, {@error, %{error: (%Changeset{} = changeset), view: view} = data}) do
      conn
      |> render(view, changeset: changeset, order: Map.get(data, :order))
    end

    def call(conn, {@error, %{error: @not_authorized, msg: msg}}) do
      conn
      |> put_flash(@error, msg)
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {@error, :invalid_account_type}) do
      conn
      |> put_flash(@error, "Not authorized to create an order")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {@error, :invalid_courier_id}) do
      conn
      |> put_flash(@error, "Invalid courier id")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {@error, :invalid_date}) do
      conn
      |> put_flash(@error, "Internal error: Failure to recognize format of pickup date.")
      |> render("new.html", changeset: Orders.change_order(%Order{}))
    end

    def call(conn, {@error, :invalid_format}) do
      conn
      |> put_flash(@error, "Internal error: Failure to recognize format of pickup date.")
      |> render("new.html", changeset: Orders.change_order(%Order{}))
    end

    def call(conn, {@error, :invalid_integer_format}) do
      conn
      |> put_flash(@error, "Internal error: Failure to recognize resource format.")
      |> render("new.html", changeset: Orders.change_order(%Order{}))
    end

    def call(conn, {@error, :invalid_order}) do
      conn
      |> put_flash(@error, "Invalid order")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {@error, :invalid_order_state}) do
      conn
      |> put_flash(@error, "Invalid order state")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {@error, :invalid_patient_id}) do
      conn
      |> put_flash(@error, "Invalid patient id")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {@error, :invalid_pharmacy_id}) do
      conn
      |> put_flash(@error, "Invalid pharmacy id")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {@error, @not_authenticated}) do
      conn
      |> put_flash(@error, "Not authorized")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {@error, @not_authorized}) do
      conn
      |> put_flash(@error, "Not authorized")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {@error, %{msg: msg}}) do
      conn
      |> put_flash(@error, msg)
      |> redirect(to: page_path(conn, :index))
    end
  end
end
