defmodule AssessmentWeb.OrderUtilities do
  import Assessment.Utilities,
    only: [get_date_today: 0, map_error: 2, nilify_error: 1, to_integer: 1]
  alias Assessment.Accounts.{Courier,Pharmacy}

  defp normalize_courier_id(params, id) do
    params
    |> Map.delete("courier_id")
    |> Map.put(:courier_id, id)
  end

  def normalize_create_params(%{"patient_id" => patient_id} = params, account) do
    whitelist = ~w(courier_id patient_id pharmacy_id pickup_date pickup_time)
    sanitized_params = Map.take(params, whitelist)
    with {:ok, new_params} <- normalize_account(sanitized_params, account),
         {:ok, pickup_date} <- normalize_date(Map.get(new_params, "pickup_date")) do
      normalized_params =
        new_params
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
  def normalize_create_params(_params, _account), do: {:error, :invalid_order}

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

  defp normalize_date_component(component) when is_binary(component) do
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

  def normalize_index_params(params, account) do
    whitelist = ~w(courier_id order_state patient_id pharmacy_id pickup_date)
    sanitized_params = Map.take(params, whitelist)
    with {:ok, new_params} <- normalize_account(sanitized_params, account),
         {:ok, pickup_date} <- normalize_date(Map.get(new_params, "pickup_date")),
         {:ok, order_state_id} <- normalize_order_state(Map.get(new_params, "order_state")),
         {:ok, patient_id} <- normalize_patient(Map.get(new_params, "patient_id")) do
      normalized_params =
        new_params
        |> Map.delete("patient_id")
        |> Map.put(:patient_id, patient_id)
        |> Map.delete("pickup_date")
        |> Map.put(:pickup_date, pickup_date)
        |> Map.delete("order_state")
        |> Map.put(:order_state_id, order_state_id)
      {:ok, normalized_params}
    end
  end

  defp normalize_order_state(order_state) do
    case order_state do
      nil             -> {:ok, 1}
      "active"        -> {:ok, 1}
      "all"           -> {:ok, :all}
      "canceled"      -> {:ok, 2}
      "delivered"     -> {:ok, 3}
      "undeliverable" -> {:ok, 4}
      _               -> {:error, :invalid_order_state}
    end
  end

  defp normalize_patient(nil), do: {:ok, :all}
  defp normalize_patient(patient_id) do
    patient_id
    |> to_integer()
    |> map_error(fn (_) -> :invalid_patient_id end)
  end

  defp normalize_pharmacy_id(params, id) do
    params
    |> Map.delete("pharmacy_id")
    |> Map.put(:pharmacy_id, id)
  end
end
