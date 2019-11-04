defmodule AssessmentWeb.OrderController do
  use AssessmentWeb, :controller

  import Assessment.Utilities, only: [get_date_today: 0, nilify_error: 1, to_integer: 1]
  alias Assessment.Accounts.{Agent,Administrator,Courier,Pharmacy}
  alias Assessment.Orders
  alias Assessment.Orders.Order
  alias AssessmentWeb.GuardianController

  plug :authorize_order_management

  action_fallback(AssessmentWeb.OrderController.ErrorController)

  def index(conn, params) do
    with {:ok, account} <- get_account(conn),
         {:ok, new_params} <- normalize_index_params(params, account) do
      orders = Orders.list_orders(new_params)
      conn
      |> assign(:normalized_params, new_params)
      |> render("index.html", orders: orders)
    end
  end

  def new(conn, _params) do
    changeset = Orders.change_order(%Order{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"order" => order_params}) do
    with {:ok, account} <- get_account(conn),
         {:ok, new_params} <- normalize_create_params(order_params, account) do
      case account do
        %Administrator{} ->
          with {:ok, order} <- Orders.create_order(new_params) do
            conn
            |> put_flash(:info, "Order created successfully.")
            |> redirect(to: order_path(conn, :show, order))
          end
        %Pharmacy{} ->
          with {:ok, order} <- Orders.create_order(new_params) do
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

  defp normalize_date(nil), do: {:ok, get_date_today() }
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
    if !Map.has_key?(params, "courier_id") || id == String.to_integer(params["courier_id"]) do
      params
      |> normalize_courier_id(id)
      |> normalize_account()
    else
      {:error, :not_authorized}
    end
  end
  defp normalize_account(params, %Pharmacy{id: id}) do
    if !Map.has_key?(params, "pharmacy_id") || id == String.to_integer(params["pharmacy_id"]) do
      params
      |> normalize_pharmacy_id(id)
      |> normalize_account()
    else
      {:error, :not_authorized}
    end
  end
  defp normalize_account(params, _account), do: normalize_account(params)
  defp normalize_account(%{"courier_id" => courier_id} = params) do
    params
    |> normalize_courier_id(courier_id)
    |> normalize_account()
  end
  defp normalize_account(%{"pharmacy_id" => pharmacy_id} = params) do
    params
    |> normalize_pharmacy_id(pharmacy_id)
    |> normalize_account()
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

  defp get_qualifier(
    account,
    %{order_state_id: order_state_id, pickup_date: pickup_date} = params) do
      count =
        case account do
          %Courier{} -> 4
          %Pharmacy{} -> 4
          _ -> 3
        end
      today? = (get_date_today() == pickup_date)
      cond do
        Enum.count(params) > count ->
          "#{if today? do "Today's " else "" end}Matching"
        order_state_id == 1 ->
          "#{if today? do "Today's " else "" end}Active"
        true ->
          "All#{if today? do " of Today's" else "" end}"
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
      _               -> {:error, :bad_order_state}
    end
  end

  defp normalize_patient(nil), do: {:ok, :all}
  defp normalize_patient(patient_id), do: to_integer(patient_id)

  defp normalize_pharmacy_id(params, id) do
    params
    |> Map.delete("pharmacy_id")
    |> Map.put(:pharmacy_id, id)
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
  end
end
