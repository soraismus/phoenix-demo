defmodule AssessmentWeb.OrderView do
  use AssessmentWeb, :view

  import Utilities, only: [get_date_today: 0]

  alias Assessment.Orders.Order

  @all :all
  @courier_id :courier_id
  @invalid_account_id :invalid_account_id
  @not_authorized :not_authorized
  @order_state :order_state
  @order_state_description :order_state_description
  @patient_id :patient_id
  @pharmacy_id :pharmacy_id
  @pickup_date :pickup_date
  @pickup_time :pickup_time
  @pop :pop

  @field_delimiter ","
  @record_delimiter "\n"

  @order_fields ~w( id
                    patient_id
                    patient_name
                    patient_address
                    pharmacy_id
                    pharmacy_name
                    pharmacy_email
                    pharmacy_address
                    courier_id
                    courier_name
                    courier_email
                    courier_address
                    order_state_description
                    pickup_date
                    pickup_time
                  )
                  |> Enum.join(@field_delimiter)

  @authorization_msg "is prohibited to unauthorized users"
  @index_id_msg "must be either 'all' or a positive integer"
  @index_order_state_msg "must be one of 'all', 'active', 'canceled', 'delivered', or 'undeliverable'"
  @index_pickup_date_msg "must either be one of 'all' or 'today' or be a valid date of the form 'YYYY-MM-DD'"
  @pickup_time_msg "must be a valid time of the form 'HH:MM'"
  @upsert_id_msg "must be specified and must be a positive integer"
  @upsert_order_state_msg "must be one of 'active', 'canceled', 'delivered', or 'undeliverable'"
  @upsert_pickup_date_msg "must either be 'today' or be a valid date of the form 'YYYY-MM-DD'"

  def current_order_state(conn) do
    case conn.params["order_state"] do
      "all" -> "all"
      _     -> "active"
    end
  end

  def current_pickup_date(conn) do
    case conn.params["pickup_date"] do
      "all" -> "all"
      _     -> "today"
    end
  end

  def format_index_errors(errors) do
    msgs =
      %{ authorization_msg: @authorization_msg,
         id_msg: @index_id_msg,
       }
    errors
    |> order_state_error_msg(@index_order_state_msg)
    |> Utilities.replace_old(@pickup_date, [@index_pickup_date_msg])
    |> Utilities.replace_old(@patient_id, [@index_id_msg])
    |> account_id_error_msg(@courier_id, msgs)
    |> account_id_error_msg(@pharmacy_id, msgs)
  end

  def format_time(%Time{} = time) do
    time |> Time.to_iso8601() |> String.slice(0..4)
  end

  def format_upsert_errors(errors) do
    msgs =
      %{ authorization_msg: @authorization_msg,
         id_msg: @upsert_id_msg,
       }
    errors
    |> order_state_error_msg(@upsert_order_state_msg)
    |> Utilities.replace_old(@pickup_date, [@upsert_pickup_date_msg])
    |> Utilities.replace_old(@pickup_time, [@pickup_time_msg])
    |> Utilities.replace_old(@patient_id, [@upsert_id_msg])
    |> account_id_error_msg(@courier_id, msgs)
    |> account_id_error_msg(@pharmacy_id, msgs)
  end

  def get_default_time(), do: {13, 0, 0}

  def get_qualifier(%{} = params) do
    order_state_description = Map.get(params, @order_state_description)
    pickup_date = Map.get(params, @pickup_date)
    today? = (get_date_today() == pickup_date)
    cond do
      order_state_description == "active" ->
        "#{if today? do "Today's " else "" end}Active"
      order_state_description == @all ->
        "All#{if today? do " of Today's" else "" end}"
      true ->
        "#{if today? do "Today's " else "" end}Matching"
    end
  end

  def is_courier?(agent) do
    !is_nil(agent) && agent.account_type == "courier"
  end

  def is_pharmacy?(agent) do
    !is_nil(agent) && agent.account_type == "pharmacy"
  end

  def next_order_state(conn) do
    case conn.params["order_state"] do
      "all" -> "active"
      _     -> "all"
    end
  end

  def next_pickup_date(conn) do
    case conn.params["pickup_date"] do
      "all" -> "today"
      _     -> "all"
    end
  end

  def order_state_label(conn) do
    case conn.params["order_state"] do
      "all" -> "Active"
      _     -> "All Order States"
    end
  end

  def pickup_date_label(conn) do
    case conn.params["pickup_date"] do
      "all" -> "Today"
      _     -> "All Dates"
    end
  end

  def to_csv([]) do
    @order_fields
  end
  def to_csv([%Order{} | _] = orders) do
    records = Enum.map_join(orders, @record_delimiter, &to_csv_record/1)
    @order_fields <> @record_delimiter <> records
  end

  defp account_id_error_msg(errors, account_id, msgs) do
    if Map.has_key?(errors, account_id) do
      case errors[account_id] do
        @not_authorized ->
          Map.put(errors, account_id, [msgs.authorization_msg])
        @invalid_account_id ->
          Map.put(errors, account_id, [msgs.id_msg])
      end
    else
      errors
    end
  end

  defp order_state_error_msg(errors, msg) do
    case Map.get_and_update(errors, @order_state_description, fn (_) -> @pop end) do
      {nil, errors} -> errors
      {_, errors} -> Map.put(errors, @order_state, [msg])
    end
  end

  defp set_off(binary) when is_binary(binary) do
    "\"#{binary}\""
  end

  defp to_csv_record(%Order{} = order) do
    [ order.id,
      order.patient.id,
      set_off(order.patient.name),
      set_off(order.patient.address),
      order.pharmacy.id,
      set_off(order.pharmacy.name),
      set_off(order.pharmacy.email),
      set_off(order.pharmacy.address),
      order.courier.id,
      set_off(order.courier.name),
      set_off(order.courier.email),
      set_off(order.courier.address),
      set_off(order.order_state.description),
      set_off(to_string(order.pickup_date)),
      set_off(order.pickup_time |> Time.to_iso8601() |> String.slice(0..4)),
    ]
    |> Enum.map_join(@field_delimiter, &to_string/1)
  end
end
