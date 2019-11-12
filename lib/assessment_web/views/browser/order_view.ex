defmodule AssessmentWeb.Browser.OrderView do
  use AssessmentWeb, :view

  import Utilities, only: [get_date_today: 0]

  alias Assessment.Orders.Order

  @pickup_date :pickup_date

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
end
