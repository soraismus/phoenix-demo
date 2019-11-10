defmodule AssessmentWeb.OrderView do
  use AssessmentWeb, :view

  import AssessmentWeb.Utilities, only: [to_changeset: 2]
  import Utilities, only: [get_date_today: 0]

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
    |> Utilities.replace_old(:pickup_date, [@index_pickup_date_msg])
    |> Utilities.replace_old(:patient_id, [@index_id_msg])
    |> account_id_error_msg(:courier_id, msgs)
    |> account_id_error_msg(:pharmacy_id, msgs)
  end

  def format_time(%Time{} = time) do
    time |> Time.to_iso8601() |> String.slice(0..4)
  end

  def format_upsert_errors(%{errors: errors, valid_results: valid_results}) do
    msgs =
      %{ authorization_msg: @authorization_msg,
         id_msg: @upsert_id_msg,
       }
    errors
    |> order_state_error_msg(@upsert_order_state_msg)
    |> Utilities.replace_old(:pickup_date, [@upsert_pickup_date_msg])
    |> Utilities.replace_old(:pickup_time, [@pickup_time_msg])
    |> Utilities.replace_old(:patient_id, [@upsert_id_msg])
    |> account_id_error_msg(:courier_id, msgs)
    |> account_id_error_msg(:pharmacy_id, msgs)
    |> to_changeset(valid_results)
  end

  def get_default_time(), do: {13, 0, 0}

  def get_qualifier(conn, %{order_state_id: order_state_id, pickup_date: pickup_date} = params) do
    count =
      case conn.assigns.agent.account_type do
        "courier" -> 4
        "pharmacy" -> 4
        _ -> 3
      end
    today? = (get_date_today() == pickup_date)
    cond do
      Enum.count(params) > count ->
        "#{if today? do "Today's " else "" end}Matching"
      order_state_id == 1 ->
        "#{if today? do "Today's " else "" end}Active"
      order_state_id == :all ->
        "All#{if today? do " of Today's" else "" end}"
      true ->
        "#{if today? do "Today's " else "" end}Matching"
    end
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

  defp account_id_error_msg(errors, account_id, msgs) do
    if Map.has_key?(errors, account_id) do
      case errors[account_id] do
        :not_authorized ->
          Map.put(errors, account_id, [msgs.authorization_msg])
        :invalid_account_id ->
          Map.put(errors, account_id, [msgs.id_msg])
      end
    else
      errors
    end
  end

  defp order_state_error_msg(errors, msg) do
    case Map.get_and_update(errors, :order_state_id, fn (_) -> :pop end) do
      {nil, errors} -> errors
      {_, errors} -> Map.put(errors, :order_state, [msg])
    end
  end
end
