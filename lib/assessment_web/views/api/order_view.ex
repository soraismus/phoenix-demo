defmodule AssessmentWeb.Api.OrderView do
  use AssessmentWeb, :view
  alias Assessment.Orders.Order
  alias Assessment.OrderStates
  alias Assessment.Utilities
  alias Assessment.Utilities.ToJson



  def render("index-errors.json", %{errors: errors}) do
    %{errors: errors |> normalize_index_errors() |> ToJson.to_json()}
  end

  defp normalize_index_errors(errors) do
    IO.inspect("normalize_index_errors errors:")
    IO.inspect(errors)
    order_state_msg =
      "Must be one of 'all', 'active', 'canceled', 'delivered', or 'undeliverable'"
    pickup_date_msg =
      "Must either be a valid date of the form 'YYYY-MM-DD' or be one of 'all' or 'today'"
    id_message =
      "Must be either 'all' or a positive integer"
    authorization_msg =
      "Is prohibited to unauthorized users"
    errors =
      case Map.get_and_update(errors, :order_state_id, fn (_) -> :pop end) do
        {nil, errors} -> errors
        {_, errors} -> Map.put(errors, :order_state, [order_state_msg])
      end
    errors = replace_old(errors, :pickup_date, [pickup_date_msg])
    errors =
      if Map.has_key?(errors, :courier_id) do
        case errors.courier_id do
          :not_authorized ->
            Map.put(errors, :courier_id, [authorization_msg])
          :invalid_account_id ->
            Map.put(errors, :courier_id, [id_message])
        end
      else
        errors
      end
    errors =
      if Map.has_key?(errors, :patient_id) do
        case errors.patient_id do
          :invalid_integer_format ->
            Map.put(errors, :patient_id, [id_message])
          _ ->
            errors
        end
      else
        errors
      end
  end

  defp replace_old(map, key, value) do
    try do
      Map.replace(map, key, value)
    rescue
      KeyError -> map
    end
  end



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

  defp display_query_params(%{order_state_id: :all} = query_params) do
    query_params
    |> Map.delete(:order_state_id)
    |> Map.put(:order_state, "all")
  end
  defp display_query_params(%{order_state_id: id} = query_params) do
    query_params
    |> Map.delete(:order_state_id)
    |> Map.put(:order_state, OrderStates.to_description(id))
  end
  defp display_query_params(query_params), do: query_params

  defimpl ToJson, for: Order do
    def to_json(%Order{order_state_id: id} = order) do
      fields = ~w(id patient pharmacy courier pickup_date pickup_time)a
      order
      |> Utilities.to_json(fields)
      |> Map.put("order_state", to_description(id))
    end
    def to_description(:all), do: "all"
    def to_description(id), do: OrderStates.to_description(id)
  end
end
