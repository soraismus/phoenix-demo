defmodule AssessmentWeb.Api.OrderView do
  use AssessmentWeb, :view
  alias Assessment.Orders.Order
  alias Assessment.OrderStates
  alias Assessment.Utilities
  alias Assessment.Utilities.ToJson

  @authorization_msg "Is prohibited to unauthorized users"
  @index_id_message "Must be either 'all' or a positive integer"
  @index_order_state_msg "Must be one of 'all', 'active', 'canceled', 'delivered', or 'undeliverable'"
  @index_pickup_date_msg "Must either be a valid date of the form 'YYYY-MM-DD' or be one of 'all' or 'today'"
  @index_pickup_date_msg "Must either be one of 'all' or 'today' or be a valid date of the form 'YYYY-MM-DD'"
  @creation_id_message "Must be specified and must be a positive integer"
  @order_state_msg "Must be one of 'all', 'active', 'canceled', 'delivered', or 'undeliverable'"
  @creation_pickup_date_msg "Must either be 'today' or be a valid date of the form 'YYYY-MM-DD'"
  @pickup_time_msg "Must be a valid time of the form 'HH:MM'"

  def render("cancel.json", %{order: order}) do
    %{canceled: %{order: ToJson.to_json(order)}}
  end

  def render("create.json", %{order: order}) do
    %{created: %{order: ToJson.to_json(order)}}
  end

  def render("creation-errors.json", %{errors: errors}) do
    %{errors: errors |> creation_error_messages() |> ToJson.to_json()}
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

  def render("index-errors.json", %{errors: errors}) do
    %{errors: errors |> index_error_messages() |> ToJson.to_json()}
  end

  def render("mark_undeliverable.json", %{order: order}) do
    %{undeliverable: %{order: ToJson.to_json(order)}}
  end

  def render("show.json", %{order: order}) do
    %{order: ToJson.to_json(order)}
  end

  defp account_id_error_message(errors, account_id, messages) do
    if Map.has_key?(errors, account_id) do
      case errors[account_id] do
        :not_authorized ->
          Map.put(errors, account_id, [messages.authorization_msg])
        :invalid_account_id ->
          Map.put(errors, account_id, [messages.id_message])
      end
    else
      errors
    end
  end

  defp creation_error_messages(errors) do
    messages =
      %{ authorization_msg: @authorization_msg,
         id_message: @creation_id_message
       }
    errors
    |> order_state_error_message()
    |> Utilities.replace_old(:pickup_date, [@creation_pickup_date_msg])
    |> Utilities.replace_old(:pickup_time, [@pickup_time_msg])
    |> Utilities.replace_old(:patient_id, [@creation_id_message])
    |> account_id_error_message(:courier_id, messages)
    |> account_id_error_message(:pharmacy_id, messages)
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

  defp index_error_messages(errors) do
    messages =
      %{ authorization_msg: @authorization_msg,
         id_message: @index_id_message
       }
    errors
    |> order_state_error_message()
    |> Utilities.replace_old(:pickup_date, [@index_pickup_date_msg])
    |> Utilities.replace_old(:patient_id, [@index_id_message])
    |> account_id_error_message(:courier_id, messages)
    |> account_id_error_message(:pharmacy_id, messages)
  end

  defp order_state_error_message(errors) do
    case Map.get_and_update(errors, :order_state_id, fn (_) -> :pop end) do
      {nil, errors} -> errors
      {_, errors} -> Map.put(errors, :order_state, [@order_state_msg])
    end
  end

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
