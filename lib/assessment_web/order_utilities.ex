defmodule AssessmentWeb.OrderUtilities do
  import Utilities,
    only: [ bind_value: 2,
            get_date_today: 0,
            map_error: 2,
            nilify_error: 1,
            to_integer: 1,
          ]

  alias Assessment.Accounts.{Administrator,Courier,Pharmacy}
  alias Assessment.Orders.Order

  def normalize_validate_update(%Order{} = order, params, account) do
    requirements = _get_required_ids(account)
    authorized? = is_integer(requirements.administrator_id)
    courier_id =
      params
      |> Map.get("courier_id")
      |> to_string()
      |> __validate_account_id_create(requirements.courier_id)
      |> bind_value(validate_order_courier(order, authorized?))
    order_state =
      params
      |> Map.get("order_state", Map.get(params, "order_state_description", "active"))
      |> __validate_order_state()
    patient_id =
      params
      |> Map.get("patient_id")
      |> to_string()
      |> __validate_id()
    pharmacy_id =
      params
      |> Map.get("pharmacy_id")
      |> to_string()
      |> __validate_account_id_create(requirements.pharmacy_id)
      |> bind_value(validate_order_pharmacy(order, authorized?))
    pickup_date =
      params
      |> Map.get("pickup_date", "today")
      |> __validate_date()
    pickup_time =
      params
      |> Map.get("pickup_time", "14:00")
      |> __validate_time()
    %{ courier_id: courier_id,
       order_state_id: order_state,
       patient_id: patient_id,
       pharmacy_id: pharmacy_id,
       pickup_date: pickup_date,
       pickup_time: pickup_time,
     }
  end


















  def normalize_validate_creation(params, account) do
    requirements = _get_required_ids(account)
    courier_id =
      params
      |> Map.get("courier_id")
      |> to_string()
      |> __validate_account_id_create(requirements.courier_id)
    order_state =
      params
      |> Map.get("order_state", Map.get(params, "order_state_description", "active"))
      |> __validate_order_state()
    patient_id =
      params
      |> Map.get("patient_id")
      |> to_string()
      |> __validate_id()
    pharmacy_id =
      params
      |> Map.get("pharmacy_id")
      |> to_string()
      |> __validate_account_id_create(requirements.pharmacy_id)
    pickup_date =
      params
      |> Map.get("pickup_date", "today")
      |> __validate_date()
    pickup_time =
      params
      |> Map.get("pickup_time", "14:00")
      |> __validate_time()
    %{ courier_id: courier_id,
       order_state_id: order_state,
       patient_id: patient_id,
       pharmacy_id: pharmacy_id,
       pickup_date: pickup_date,
       pickup_time: pickup_time,
     }
  end

  def normalize_validate_index(params, account) do
    requirements = _get_required_ids(account)
    courier_id =
      params
      |> Map.get("courier_id")
      |> to_string()
      |> __validate_account_id_index(requirements.courier_id)
    order_state =
      params
      |> Map.get("order_state", Map.get(params, "order_state_description", "active"))
      |> check_all_or_validate(&__validate_order_state/1)
    patient_id =
      params
      |> Map.get("patient_id", "all")
      |> to_string()
      |> check_all_or_validate(&__validate_id/1)
    pharmacy_id =
      params
      |> Map.get("pharmacy_id")
      |> to_string()
      |> __validate_account_id_index(requirements.pharmacy_id)
    pickup_date =
      params
      |> Map.get("pickup_date", "today")
      |> check_all_or_validate(&__validate_date/1)
    %{ courier_id: courier_id,
       order_state_id: order_state,
       patient_id: patient_id,
       pharmacy_id: pharmacy_id,
       pickup_date: pickup_date,
     }
  end
  defp check_all_or_validate(id, fun) do
    if id == "all" do
      {:ok, :all}
    else
      fun.(id)
    end
  end

  defp __validate_account_id_create(account_id, required_id)
    when is_binary(account_id) and is_nil(required_id) do
      __validate_id(account_id)
  end
  defp __validate_account_id_create(account_id, required_id)
    when is_binary(account_id) and is_integer(required_id) do
      cond do
        account_id == "" ->
          {:ok, required_id}
        account_id == to_string(required_id) ->
          {:ok, required_id}
        true ->
          case to_integer(account_id) do
            {:ok, _} ->
              {:error, :not_authorized}
            {:error, _} ->
              {:error, :invalid_account_id}
          end
      end
  end

  defp validate_order_courier(%Order{} = order, authorized?) do
    fn (courier_id) ->
      cond do
        authorized? ->
          {:ok, courier_id}
        order.courier_id == courier_id ->
          {:ok, courier_id}
        true ->
          {:error, :not_authorized}
      end
    end
  end

  defp validate_order_pharmacy(%Order{} = order, authorized?) do
    fn (pharmacy_id) ->
      cond do
        authorized? ->
          {:ok, pharmacy_id}
        order.pharmacy_id == pharmacy_id ->
          {:ok, pharmacy_id}
        true ->
          {:error, :not_authorized}
      end
    end
  end

  defp __validate_account_id_index(account_id, required_id)
    when is_binary(account_id) and is_nil(required_id) do
      cond do
        account_id == "" ->
          {:ok, :all}
        account_id == "all" ->
          {:ok, :all}
        true ->
          __validate_id(account_id)
      end
  end
  defp __validate_account_id_index(account_id, required_id)
    when is_binary(account_id) and is_integer(required_id) do
      cond do
        account_id == "" ->
          {:ok, required_id}
        account_id == to_string(required_id) ->
          {:ok, required_id}
        true ->
          case to_integer(account_id) do
            {:ok, _} ->
              {:error, :not_authorized}
            {:error, _} ->
              {:error, :invalid_account_id}
          end
      end
  end

  defp __validate_order_state("active"), do: {:ok, 1}
  defp __validate_order_state("canceled"), do: {:ok, 2}
  defp __validate_order_state("delivered"), do: {:ok, 3}
  defp __validate_order_state("undeliverable"), do: {:ok, 4}
  defp __validate_order_state(_), do: {:error, :invalid_order_state}

  defp __validate_id(id) do
    msg = :invalid_account_id
    id
    |> to_integer()
    |> bind_value(fn (id) -> if (id > 0), do: {:ok, id}, else: {:error, msg} end)
    |> map_error(fn (_) -> msg end)
  end

  defp __validate_date("today"), do: {:ok, get_date_today() }
  defp __validate_date(%{"year" => year, "month" => month, "day" => day}) do
    month = __normalize_datetime_segment(month)
    day = __normalize_datetime_segment(day)
    Date.from_iso8601("#{year}-#{month}-#{day}")
  end
  defp __validate_date(iso8601_date_or_error) do
    Date.from_iso8601(iso8601_date_or_error)
  end
  defp __normalize_datetime_segment(segment) do
    if String.length(segment) == 1 do
      "0#{segment}"
    else
      segment
    end
  end
  defp __validate_time(%{"hour" => hour, "minute" => minute}) do
    hour = __normalize_datetime_segment(hour)
    minute = __normalize_datetime_segment(minute)
    Time.from_iso8601("#{hour}:#{minute}:00")
  end
  defp __validate_time(iso8601_time_or_error) do
    Time.from_iso8601("#{iso8601_time_or_error}:00")
  end

  defp _get_required_ids(account) do
    case account do
      %Courier{id: id} ->
        %{courier_id: id, pharmacy_id: nil, administrator_id: nil}
      %Pharmacy{id: id} ->
        %{courier_id: nil, pharmacy_id: id, administrator_id: nil}
      %Administrator{id: id} ->
        %{courier_id: nil, pharmacy_id: nil, administrator_id: id}
    end
  end
end
