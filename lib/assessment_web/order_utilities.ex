defmodule AssessmentWeb.OrderUtilities do
  import Utilities,
    only: [ bind_value: 2,
            get_date_today: 0,
            map_error: 2,
            to_integer: 1,
          ]

  alias Assessment.Accounts.{Administrator,Courier,Pharmacy}
  alias Assessment.Orders.Order
  alias Assessment.OrderStates
  alias Assessment.OrderStates.OrderState

  @default_order_state OrderState.active()
  @default_pickup_date "today"
  @default_pickup_time "14:00"

  @all :all
  @error :error
  @invalid_account_id :invalid_account_id
  @invalid_date :invalid_date
  @invalid_time :invalid_time
  @not_authorized :not_authorized
  @ok :ok

  def normalize_validate_creation(params, account) do
    requirements = get_required_ids(account)
    courier_id =
      params
      |> Map.get("courier_id")
      |> to_string()
      |> validate_account_id_upsert(requirements.courier_id)
    order_state =
      params
      |> Map.get(
            "order_state",
            Map.get(params, "order_state_description", @default_order_state))
      |> OrderStates.to_id()
    patient_id =
      params
      |> Map.get("patient_id")
      |> to_string()
      |> validate_id()
    pharmacy_id =
      params
      |> Map.get("pharmacy_id")
      |> to_string()
      |> validate_account_id_upsert(requirements.pharmacy_id)
    pickup_date =
      params
      |> Map.get("pickup_date", @default_pickup_date)
      |> validate_date()
    pickup_time =
      params
      |> Map.get("pickup_time", @default_pickup_time)
      |> validate_time()
    %{ courier_id: courier_id,
       order_state_id: order_state,
       patient_id: patient_id,
       pharmacy_id: pharmacy_id,
       pickup_date: pickup_date,
       pickup_time: pickup_time,
     }
  end

  def normalize_validate_index(params, account) do
    requirements = get_required_ids(account)
    courier_id =
      params
      |> Map.get("courier_id")
      |> to_string()
      |> validate_account_id_index(requirements.courier_id)
    order_state =
      params
      |> Map.get(
            "order_state",
            Map.get(params, "order_state_description", @default_order_state))
      |> check_all_or_validate(&OrderStates.to_id/1)
    patient_id =
      params
      |> Map.get("patient_id", "all")
      |> to_string()
      |> check_all_or_validate(&validate_id/1)
    pharmacy_id =
      params
      |> Map.get("pharmacy_id")
      |> to_string()
      |> validate_account_id_index(requirements.pharmacy_id)
    pickup_date =
      params
      |> Map.get("pickup_date", @default_pickup_date)
      |> check_all_or_validate(&validate_date/1)
    %{ courier_id: courier_id,
       order_state_id: order_state,
       patient_id: patient_id,
       pharmacy_id: pharmacy_id,
       pickup_date: pickup_date,
     }
  end

  def normalize_validate_update(%Order{} = order, params, account) do
    requirements = get_required_ids(account)
    authorized? = is_integer(requirements.administrator_id)
    courier_id =
      params
      |> Map.get("courier_id")
      |> to_string()
      |> validate_account_id_upsert(requirements.courier_id)
      |> bind_value(validate_order_courier(order, authorized?))
    order_state =
      params
      |> Map.get(
            "order_state",
            Map.get(params, "order_state_description", @default_order_state))
      |> OrderStates.to_id()
    patient_id =
      params
      |> Map.get("patient_id")
      |> to_string()
      |> validate_id()
    pharmacy_id =
      params
      |> Map.get("pharmacy_id")
      |> to_string()
      |> validate_account_id_upsert(requirements.pharmacy_id)
      |> bind_value(validate_order_pharmacy(order, authorized?))
    pickup_date =
      params
      |> Map.get("pickup_date", @default_pickup_date)
      |> validate_date()
    pickup_time =
      params
      |> Map.get("pickup_time", @default_pickup_time)
      |> validate_time()
    %{ courier_id: courier_id,
       order_state_id: order_state,
       patient_id: patient_id,
       pharmacy_id: pharmacy_id,
       pickup_date: pickup_date,
       pickup_time: pickup_time,
     }
  end

  defp check_all_or_validate(id, fun) do
    if id == "all" do
      {@ok, @all}
    else
      fun.(id)
    end
  end

  defp get_required_ids(account) do
    case account do
      %Courier{id: id} ->
        %{courier_id: id, pharmacy_id: nil, administrator_id: nil}
      %Pharmacy{id: id} ->
        %{courier_id: nil, pharmacy_id: id, administrator_id: nil}
      %Administrator{id: id} ->
        %{courier_id: nil, pharmacy_id: nil, administrator_id: id}
    end
  end

  defp normalize_datetime_segment(segment) do
    if String.length(segment) == 1 do
      "0#{segment}"
    else
      segment
    end
  end

  defp validate_account_id_index(account_id, required_id)
    when is_binary(account_id) and is_nil(required_id) do
      cond do
        account_id == "" ->
          {@ok, @all}
        account_id == "all" ->
          {@ok, @all}
        true ->
          validate_id(account_id)
      end
  end
  defp validate_account_id_index(account_id, required_id)
    when is_binary(account_id) and is_integer(required_id) do
      cond do
        account_id == "" ->
          {@ok, required_id}
        account_id == to_string(required_id) ->
          {@ok, required_id}
        true ->
          case to_integer(account_id) do
            {@ok, _} ->
              {@error, @not_authorized}
            {@error, _} ->
              {@error, @invalid_account_id}
          end
      end
  end

  defp validate_account_id_upsert(account_id, required_id)
    when is_binary(account_id) and is_nil(required_id) do
      validate_id(account_id)
  end
  defp validate_account_id_upsert(account_id, required_id)
    when is_binary(account_id) and is_integer(required_id) do
      cond do
        account_id == "" ->
          {@ok, required_id}
        account_id == to_string(required_id) ->
          {@ok, required_id}
        true ->
          case to_integer(account_id) do
            {@ok, _} ->
              {@error, @not_authorized}
            {@error, _} ->
              {@error, @invalid_account_id}
          end
      end
  end

  defp validate_date("today"), do: {@ok, get_date_today() }
  defp validate_date(%{"year" => year, "month" => month, "day" => day}) do
    month = normalize_datetime_segment(month)
    day = normalize_datetime_segment(day)
    validate_date("#{year}-#{month}-#{day}")
  end
  defp validate_date(iso8601_date_or_error) do
    iso8601_date_or_error
    |> Date.from_iso8601()
    |> map_error(fn (_) -> @invalid_date end)
  end

  defp validate_id(id) do
    msg = @invalid_account_id
    id
    |> to_integer()
    |> bind_value(fn (id) -> if (id > 0), do: {@ok, id}, else: {@error, msg} end)
    |> map_error(fn (_) -> msg end)
  end

  defp validate_order_courier(%Order{} = order, authorized?) do
    fn (courier_id) ->
      cond do
        authorized? ->
          {@ok, courier_id}
        order.courier_id == courier_id ->
          {@ok, courier_id}
        true ->
          {@error, @not_authorized}
      end
    end
  end

  defp validate_order_pharmacy(%Order{} = order, authorized?) do
    fn (pharmacy_id) ->
      cond do
        authorized? ->
          {@ok, pharmacy_id}
        order.pharmacy_id == pharmacy_id ->
          {@ok, pharmacy_id}
        true ->
          {@error, @not_authorized}
      end
    end
  end

  defp validate_time(%{"hour" => hour, "minute" => minute}) do
    nhour = normalize_datetime_segment(hour)
    nminute = normalize_datetime_segment(minute)
    validate_time("#{nhour}:#{nminute}")
  end
  defp validate_time(iso8601_time_or_error)
    when is_binary(iso8601_time_or_error) do
      "#{iso8601_time_or_error}:00"
      |> Time.from_iso8601()
      |> map_error(fn (_) -> @invalid_time end)
  end
end
