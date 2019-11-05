defmodule AssessmentWeb.OrderController do
  use AssessmentWeb, :controller

  import Assessment.Utilities,
    only: [error_data: 1, get_date_today: 0, map_error: 2, nilify_error: 1, to_integer: 1]
  alias Assessment.Accounts.{Agent,Administrator,Courier,Pharmacy}
  alias Assessment.Orders
  alias Assessment.Orders.Order
  alias Ecto.Changeset

  plug :authorize_order_management

  action_fallback(AssessmentWeb.OrderController.ErrorController)

  def index(conn, params) do
    with {:ok, account} <- get_account(conn),
         {:ok, normalized_params} <- normalize_index_params(params, account) do
      orders = Orders.list_orders(normalized_params)
      conn
      |> assign(:normalized_params, normalized_params)
      |> render("index.html", orders: orders)
    end
  end

  def new(conn, _params) do
    changeset = Orders.change_order(%Order{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"order" => order_params}) do
    data = %{msg: "Not authorized to create an order", view: "new.html"}
    with {:ok, account} <- get_account(conn),
         {:ok, new_params} <- normalize_create_params(order_params, account),
         {:ok, _} <- authorize_admin_or_pharmacy(account) |> error_data(data).(),
         {:ok, order} <- Orders.create_order(new_params) |> error_data(data).() do
      conn
      |> put_flash(:info, "Order created successfully.")
      |> redirect(to: order_path(conn, :show, order))
    end
  end

  defp authorize_admin_or_pharmacy(account) do
    case account do
      %Administrator{} -> {:ok, account}
      %Pharmacy{} -> {:ok, account}
      _ -> {:error, :not_authorized}
    end
  end

  def show(conn, %{"id" => id}) do
    data = %{msg: "Invalid order id"}
    with {:ok, account} <- get_account(conn),
         {:ok, order} <- Orders.get_order(id) |> error_data(data).(),
         {:ok, _} <- authorize(account, order, "Not authorized to view order") do
      render(conn, "show.html", order: order)
    end
  end

  defp authorize(account, order, msg) do
    authorized? = case account do
      %Administrator{} -> true
      %Courier{} -> account.id == order.courier_id
      %Pharmacy{} -> account.id == order.pharmacy_id
    end
    if authorized? do
      {:ok, account}
    else
      {:error, %{error: :not_authorized, msg: msg}}
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, order} <- Orders.get_order(id) do
      changeset = Orders.change_order(order)
      render(conn, "edit.html", order: order, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "order" => order_params}) do
    data = %{msg: "Invalid order id", view: "edit.html"}
    with {:ok, account} <- get_account(conn),
         {:ok, order} <- Orders.get_order(id) |> error_data(data).(),
         {:ok, _} <- authorize(account, order, "Not authorized to view order"),
         {:ok, new_params} <- normalize_edit_params(order_params, account),
         data <- Map.put(data, :order, order),
         {:ok, _} <- Orders.update_order(order, new_params) |> error_data(data).() do
      conn
      |> put_flash(:info, "Order updated successfully.")
      |> redirect(to: order_path(conn, :show, order))
    end
  end

  def delete(conn, %{"id" => id}) do
    data = %{msg: "Invalid order id"}
    with {:ok, account} <- get_account(conn),
         {:ok, order} <- Orders.get_order(id) |> error_data(data).(),
         {:ok, _} <- authorize(account, order, "Not authorized to delete order"),
         {:ok, _} <- Orders.delete_order(order) do
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

  defp normalize_courier_id(params, id) do
    params
    |> Map.delete("courier_id")
    |> Map.put(:courier_id, id)
  end

  defp normalize_create_params(%{"patient_id" => patient_id} = params, account) do
    whitelist = ~w(courier_id patient_id pharmacy_id pickup_date pickup_time)
    sanitized_params = Map.take(params, whitelist)
    with {:ok, new_params} <- normalize_account(sanitized_params, account),
         {:ok, pickup_date} <- normalize_date(Map.get(new_params, "pickup_date")) do
      normalized_params =
        new_params
        |> Map.delete("patient_id")
        |> Map.put(:patient_id, patient_id)
        |> Map.delete("pickup_date")
        |> Map.put(:pickup_date, pickup_date)
        |> Map.delete("pickup_time")
        |> Map.put(:pickup_time, Map.get(new_params, "pickup_time"))
        |> Map.put(:order_state_id, 1)
      {:ok, normalized_params}
    end
  end
  defp normalize_create_params(_params, _account), do: {:error, :invalid_order}

  defp normalize_edit_params(%{"patient_id" => patient_id} = params, account) do
    whitelist =
      ~w( courier_id
          order_state_description
          patient_id
          pharmacy_id
          pickup_date
          pickup_time
        )
    sanitized_params = Map.take(params, whitelist)
    with {:ok, new_params} <- normalize_account(sanitized_params, account),
         {:ok, pickup_date} <- normalize_date(Map.get(new_params, "pickup_date")) do
      normalized_params =
        new_params
        |> Map.delete("order_state_description")
        |> Map.put(:order_state_description, Map.get(params, "order_state_description"))
        |> Map.delete("patient_id")
        |> Map.put(:patient_id, patient_id)
        |> Map.delete("pickup_date")
        |> Map.put(:pickup_date, pickup_date)
        |> Map.delete("pickup_time")
        |> Map.put(:pickup_time, Map.get(new_params, "pickup_time"))
        |> Map.put(:order_state_id, 1)
      {:ok, normalized_params}
    end
  end
  defp normalize_edit_params(_params, _account), do: {:error, :invalid_order}

  defp normalize_date(nil), do: {:ok, get_date_today()}
  defp normalize_date("all"), do: {:ok, :all}
  defp normalize_date("today"), do: {:ok, get_date_today() }
  defp normalize_date(%{"day" => day, "month" => month, "year" => year}) do
    normalize_date("#{year}-#{normalize_date_component(month)}-#{normalize_date_component(day)}")
  end
  defp normalize_date(iso8601_date), do: Date.from_iso8601(iso8601_date)

  defp normalize_date_component(component) when is_binary(component) do
    if String.length(component) == 1 do
      "0#{component}"
    else
      component
    end
  end

  # The main purpose of the following `normalize_account` function is
  # to prevent pharmacies from acccessing other pharmacies' data
  # and to prevent couriers from acccessing other couriers' data.
  defp normalize_account(params, %Courier{id: id}) do
    lacks_courier? = !Map.has_key?(params, "courier_id")
    if lacks_courier? || id == nilify_error(to_integer(params["courier_id"])) do
      params
      |> normalize_courier_id(id)
      |> normalize_account()
    else
      {:error, :not_authorized}
    end
  end
  defp normalize_account(params, %Pharmacy{id: id}) do
    lacks_pharmacy? = !Map.has_key?(params, "pharmacy_id")
    if lacks_pharmacy? || id == nilify_error(to_integer(params["pharmacy_id"])) do
      params
      |> normalize_pharmacy_id(id)
      |> normalize_account()
    else
      {:error, :not_authorized}
    end
  end
  defp normalize_account(params, _account), do: normalize_account(params)
  defp normalize_account(%{"courier_id" => courier_id} = params) do
    with {:ok, checked_courier_id} <- to_integer(courier_id) do
      params
      |> normalize_courier_id(checked_courier_id)
      |> normalize_account()
    else
      _ -> {:error, :invalid_courier_id}
    end
  end
  defp normalize_account(%{"pharmacy_id" => pharmacy_id} = params) do
    with {:ok, checked_pharmacy_id} <- to_integer(pharmacy_id) do
      params
      |> normalize_pharmacy_id(checked_pharmacy_id)
      |> normalize_account()
    else
      _ -> {:error, :invalid_pharmacy_id}
    end
  end
  defp normalize_account(params), do: {:ok, params}

  defp normalize_index_params(params, account) do
    whitelist = ~w(courier_id order_state patient_id pharmacy_id pickup_date)
    sanitized_params = Map.take(params, whitelist)
    with {:ok, new_params} <- normalize_account(sanitized_params, account),
         {:ok, pickup_date} <- normalize_date(Map.get(new_params, "pickup_date")),
         {:ok, order_state_id} <- normalize_order_state(Map.get(new_params, "order_state")),
         {:ok, patient_id} <- normalize_patient(Map.get(new_params, "patient_id")) do
      normalized_params =
        new_params
        |> Map.delete("patient_id")
        |> Map.put(:patient_id, patient_id)
        |> Map.delete("pickup_date")
        |> Map.put(:pickup_date, pickup_date)
        |> Map.delete("order_state")
        |> Map.put(:order_state_id, order_state_id)
      {:ok, normalized_params}
    end
  end

  defp normalize_order_state(order_state) do
    case order_state do
      nil             -> {:ok, 1}
      "active"        -> {:ok, 1}
      "all"           -> {:ok, :all}
      "canceled"      -> {:ok, 2}
      "delivered"     -> {:ok, 3}
      "undeliverable" -> {:ok, 4}
      _               -> {:error, :invalid_order_state}
    end
  end

  defp normalize_patient(nil), do: {:ok, :all}
  defp normalize_patient(patient_id) do
    patient_id
    |> to_integer()
    |> map_error(fn (_) -> :invalid_patient_id end)
  end

  defp normalize_pharmacy_id(params, id) do
    params
    |> Map.delete("pharmacy_id")
    |> Map.put(:pharmacy_id, id)
  end

  defmodule ErrorController do
    use AssessmentWeb, :controller

    def call(conn, {:error, %{error: (%Changeset{} = changeset), view: view} = data}) do
      render(conn, view, changeset: changeset, order: Map.get(data, :order))
    end

    def call(conn, {:error, %{error: :not_authorized, msg: msg}}) do
      conn
      |> put_flash(:error, msg)
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {:error, {:update_order, {%Order{} = order, %Ecto.Changeset{} = changeset}}}) do
      render(conn, "edit.html", order: order, changeset: changeset)
    end

    def call(conn, {:error, :invalid_account_type}) do
      conn
      |> put_flash(:error, "Not authorized to create an order")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {:error, :invalid_courier_id}) do
      conn
      |> put_flash(:error, "Invalid courier id")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {:error, :invalid_date}) do
      conn
      |> put_flash(:error, "Internal error: Failure to recognize format of pickup date.")
      |> render("new.html", changeset: Orders.change_order(%Order{}))
    end

    def call(conn, {:error, :invalid_format}) do
      conn
      |> put_flash(:error, "Internal error: Failure to recognize format of pickup date.")
      |> render("new.html", changeset: Orders.change_order(%Order{}))
    end

    def call(conn, {:error, :invalid_integer_format}) do
      conn
      |> put_flash(:error, "Internal error: Failure to recognize resource format.")
      |> render("new.html", changeset: Orders.change_order(%Order{}))
    end

    def call(conn, {:error, :invalid_order}) do
      conn
      |> put_flash(:error, "Invalid order")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {:error, :invalid_order_state}) do
      conn
      |> put_flash(:error, "Invalid order state")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {:error, :invalid_patient_id}) do
      conn
      |> put_flash(:error, "Invalid patient id")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {:error, :invalid_pharmacy_id}) do
      conn
      |> put_flash(:error, "Invalid pharmacy id")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {:error, :not_authenticated}) do
      conn
      |> put_flash(:error, "Not authorized")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {:error, :not_authorized}) do
      conn
      |> put_flash(:error, "Not authorized")
      |> redirect(to: page_path(conn, :index))
    end

    def call(conn, {:error, %{msg: msg}}) do
      conn
      |> put_flash(:error, msg)
      |> redirect(to: page_path(conn, :index))
    end

  end
end
