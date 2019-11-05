defmodule AssessmentWeb.OrderView do
  use AssessmentWeb, :view
  import Assessment.Utilities, only: [get_date_today: 0]

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

  def format_time(%Time{} = time) do
    time |> Time.to_iso8601() |> String.slice(0..4)
  end

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

  def get_default_time(), do: {13, 0, 0}

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
end
