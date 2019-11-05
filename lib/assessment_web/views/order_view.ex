defmodule AssessmentWeb.OrderView do
  use AssessmentWeb, :view
  import Assessment.Utilities, only: [get_date_today: 0]

  def format_time(%Time{} = time) do
    time |> Time.to_iso8601() |> String.slice(0..4)
  end

  def get_qualifier(conn, %{order_state_id: order_state_id, pickup_date: pickup_date} = params) do
    IO.inspect(params)
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

  def get_time_now(), do: Time.utc_now() |> format_time()
end
