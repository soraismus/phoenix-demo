defmodule AssessmentWeb.OrderUtilities do
  import Assessment.Utilities,
    only: [ bind_value: 2,
            get_date_today: 0,
            map_error: 2,
            nilify_error: 1,
            to_integer: 1,
          ]
  alias Assessment.Accounts.{Courier,Pharmacy}

  defp normalize_courier_id(params, id) do
    params
    |> Map.delete("courier_id")
    |> Map.put(:courier_id, id)
  end

  def normalize_edit_params(%{"patient_id" => patient_id} = params, account) do
    whitelist =
      ~w( courier_id
          order_state_description
          patient_id
          pharmacy_id
          pickup_date
          pickup_time
        )
    sanitized_params = Map.take(params, whitelist)
    with {:ok, new_params} <- normalize_account(sanitized_params, account),
         {:ok, pickup_date} <- normalize_date(Map.get(new_params, "pickup_date")) do
      normalized_params =
        new_params
        |> Map.delete("order_state_description")
        |> Map.put(:order_state_description, Map.get(params, "order_state_description"))
        |> Map.delete("patient_id")
        |> Map.put(:patient_id, patient_id)
        |> Map.delete("pickup_date")
        |> Map.put(:pickup_date, pickup_date)
        |> Map.delete("pickup_time")
        |> Map.put(:pickup_time, Map.get(new_params, "pickup_time"))
        |> Map.put(:order_state_id, 1)
      {:ok, normalized_params}
    end
  end
  def normalize_edit_params(_params, _account), do: {:error, :invalid_order}

  defp normalize_date(nil), do: {:ok, get_date_today()}
  defp normalize_date("all"), do: {:ok, :all}
  defp normalize_date("today"), do: {:ok, get_date_today() }
  defp normalize_date(%{"day" => day, "month" => month, "year" => year}) do
    normalize_date("#{year}-#{normalize_date_component(month)}-#{normalize_date_component(day)}")
  end
  defp normalize_date(iso8601_date) do
    iso8601_date
    |> Date.from_iso8601()
    |> map_error(fn (_) -> :invalid_date_format end)
  end

  defp normalize_date_component(component) do
    if String.length(component) == 1 do
      "0#{component}"
    else
      component
    end
  end

  # The main purpose of the following `normalize_account` function is
  # to prevent pharmacies from acccessing other pharmacies' data
  # and to prevent couriers from acccessing other couriers' data.
  defp normalize_account(params, %Courier{id: id}) do
    lacks_courier? = !Map.has_key?(params, "courier_id")
    if lacks_courier? || id == nilify_error(to_integer(params["courier_id"])) do
      params
      |> normalize_courier_id(id)
      |> normalize_account()
    else
      {:error, :not_authorized}
    end
  end
  defp normalize_account(params, %Pharmacy{id: id}) do
    lacks_pharmacy? = !Map.has_key?(params, "pharmacy_id")
    if lacks_pharmacy? || id == nilify_error(to_integer(params["pharmacy_id"])) do
      params
      |> normalize_pharmacy_id(id)
      |> normalize_account()
    else
      {:error, :not_authorized}
    end
  end
  defp normalize_account(params, _account), do: normalize_account(params)
  defp normalize_account(%{"courier_id" => courier_id} = params) do
    with {:ok, checked_courier_id} <- to_integer(courier_id) do
      params
      |> normalize_courier_id(checked_courier_id)
      |> normalize_account()
    else
      _ -> {:error, :invalid_courier_id}
    end
  end
  defp normalize_account(%{"pharmacy_id" => pharmacy_id} = params) do
    with {:ok, checked_pharmacy_id} <- to_integer(pharmacy_id) do
      params
      |> normalize_pharmacy_id(checked_pharmacy_id)
      |> normalize_account()
    else
      _ -> {:error, :invalid_pharmacy_id}
    end
  end
  defp normalize_account(params), do: {:ok, params}

  defp normalize_pharmacy_id(params, id) do
    params
    |> Map.delete("pharmacy_id")
    |> Map.put(:pharmacy_id, id)
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
      |> Map.get("order_state", "active")
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
      |> Map.get("order_state", "active")
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
      (%Courier{id: id}) ->
        %{courier_id: id, pharmacy_id: nil}
      (%Pharmacy{id: id}) ->
        %{courier_id: nil, pharmacy_id: id}
      _ ->
        %{courier_id: nil, pharmacy_id: nil}
    end
  end
end
