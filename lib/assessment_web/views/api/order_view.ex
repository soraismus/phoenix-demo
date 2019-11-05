defmodule AssessmentWeb.Api.OrderView do
  use AssessmentWeb, :view
  alias Assessment.Orders.Order
  alias Assessment.OrderStates.OrderState
  alias Assessment.Utilities
  alias Assessment.Utilities.ToJson

  def render("create.json", %{order: order}) do
    %{created: %{order: ToJson.to_json(order)}}
  end

  def render("index.json", %{orders: orders}) do
    %{
      count: length(orders),
      orders: ToJson.to_json(orders),
    }
  end

  def render("show.json", %{order: order}) do
    %{order: ToJson.to_json(order)}
  end

  defimpl ToJson, for: Order do
    def to_json(%Order{} = order) do
      fields = ~w(id patient pharmacy courier order_state pickup_date pickup_time)a
      order
      |> Utilities.to_json(fields)
    end
  end

  defimpl ToJson, for: OrderState do
    def to_json(%OrderState{} = order_state) do
      order_state.description
    end
  end

  defimpl ToJson, for: Time do
    def to_json(%Time{} = time) do
      format_time(time)
    end

    defp format_time(%Time{} = time) do
      time |> Time.to_iso8601() |> String.slice(0..4)
    end
  end
end
