defmodule AssessmentWeb.Api.OrderView do
  use AssessmentWeb, :view
  alias Assessment.Orders.Order
  alias Assessment.OrderStates
  alias Assessment.Utilities
  alias Assessment.Utilities.ToJson

  def render("cancel.json", %{order: order}) do
    %{canceled: %{order: ToJson.to_json(order)}}
  end

  def render("create.json", %{order: order}) do
    %{created: %{order: ToJson.to_json(order)}}
  end

  def render("deliver.json", %{order: order}) do
    %{delivered: %{order: ToJson.to_json(order)}}
  end

  def render("index.json", %{orders: orders, query_params: query_params}) do
    %{
      count: length(orders),
      orders: ToJson.to_json(orders),
      query_params: display_query_params(query_params),
    }
  end

  def render("mark_undeliverable.json", %{order: order}) do
    %{undeliverable: %{order: ToJson.to_json(order)}}
  end

  def render("show.json", %{order: order}) do
    %{order: ToJson.to_json(order)}
  end

  defp display_query_params(%{order_state_id: order_state_id} = query_params) do
    %{query_params | order_state_id: OrderStates.to_description(order_state_id)}
  end
  defp display_query_params(query_params), do: query_params

  defimpl ToJson, for: Order do
    def to_json(%Order{} = order) do
      fields = ~w(id patient pharmacy courier pickup_date pickup_time)a
      order
      |> Utilities.to_json(fields)
      |> Map.put("order_state", OrderStates.to_description(order.order_state_id))
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
