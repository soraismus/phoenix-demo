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


















def _normalize_create(params, account) do
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
def _normalize_index(params, account) do
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
def __validate_account_id_create(account_id, required_id)
  when is_binary(account_id) and is_nil(required_id) do
    __validate_id(account_id)
end
def __validate_account_id_create(account_id, required_id)
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
def __validate_account_id_index(account_id, required_id)
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
def __validate_account_id_index(account_id, required_id)
  when is_binary(account_id) and is_integer(required_id) do
    cond do
      account_id == "" ->
        {:ok, :all}
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
def __validate_order_state("active"), do: {:ok, 1}
def __validate_order_state("canceled"), do: {:ok, 2}
def __validate_order_state("delivered"), do: {:ok, 3}
def __validate_order_state("undeliverable"), do: {:ok, 4}
def __validate_order_state(_), do: {:error, :invalid_order_state}
def __validate_id(id) do
  msg = :invalid_account_id
  id
  |> to_integer()
  |> bind_value(fn (id) -> if (id > 0), do: {:ok, id}, else: {:error, msg} end)
  |> map_error(fn (_) -> msg end)
end
def __validate_date("today"), do: {:ok, get_date_today() }
def __validate_date(%{"day" => day, "month" => month, "year" => year}) do
  "#{year}-#{normalize_date_component(month)}-#{normalize_date_component(day)}"
  |> Date.from_iso8601()
end
def __validate_date(iso8601_date_or_error) do
  Date.from_iso8601(iso8601_date_or_error)
end
def __validate_date_component(component) do
  if String.length(component) == 1 do
    "0#{component}"
  else
    component
  end
end
def __validate_time(iso8601_time_or_error) do
  Time.from_iso8601("#{iso8601_time_or_error}:00")
end


    #CHANGESET NOT NEEDED

import Ecto.Changeset
alias Ecto.Changeset
def _get_required_ids(account) do
  case account do
    (%Courier{id: id}) ->
      %{courier_id: id, pharmacy_id: nil}
    (%Pharmacy{id: id}) ->
      %{courier_id: nil, pharmacy_id: id}
    _ ->
      %{courier_id: nil, pharmacy_id: nil}
  end
end
def _normalize_and_validate(params, account) do
  requirements = _get_required_ids(account)
  courier_id = Map.get(params, "courier_id", requirements.courier_id || "all")
  order_state = Map.get(params, "order_state", "active")
  patient_id = Map.get(params, "patient_id", "all")
  pharmacy_id = Map.get(params, "pharmacy_id", requirements.pharmacy_id || "all")
  pickup_date = Map.get(params, "pickup_date", "today")
  normalized_attrs =
    %{ courier_id: _normalize_id(courier_id),
       order_state: _normalize_order_state(order_state),
       patient_id: _normalize_id(patient_id),
       pharmacy_id: _normalize_id(pharmacy_id),
       pickup_date: _normalize_date(pickup_date),
     }
  changeset = _validate(normalized_attrs, requirements)
  if changeset.valid? do
    _normalized_attrs =
      normalized_attrs
      |> Enum.reduce(
          %{},
          fn ({key, {:ok, value}}, map) -> Map.put(map, key, value) end)
    {:ok, _normalized_attrs}
  else
    {:error, changeset}
  end
end
def _validate(normalized_attrs, requirements) do
  changeset =
    { %{},
      %{ courier_id: :any,
         order_state: :any,
         patient_id: :any,
         pharmacy_id: :any,
         pickup_date: :any,
       }
    }
    |> Changeset.cast(
          normalized_attrs,
          ~w(courier_id order_state patient_id pharmacy_id pickup_date)a)
    |> _validate_courier_id(to_string(requirements.courier_id))
    |> _validate_order_state()
    |> _validate_patient_id()
    |> _validate_pharmacy_id(to_string(requirements.pharmacy_id))
    |> _validate_pickup_date()
end
def _normalize_id("all"), do: {:ok, :all}
def _normalize_id(id) do
  with {:ok, int} <- to_integer(id) do
    if int > 0 do
      {:ok, int}
    else
      {:error, :invalid_natural_number}
    end
  end
end
def _validate_courier_id(changeset, required_id) do
  validate_change(changeset, :courier_id, fn (:courier_id, result) ->
      case result do
        {:ok, id} ->
          cond do
            is_nil(required_id)
              -> []
            to_string(id) == required_id
              -> []
            true ->
              [courier_id: "Is prohibited for this user"]
          end
        {:error, _} ->
          [courier_id: "Must be a positive integer"]
      end
    end)
end
def _validate_pharmacy_id(changeset, required_id) do
  validate_change(changeset, :pharmacy_id, fn (:pharmacy_id, result) ->
      case result do
        {:ok, id} ->
          cond do
            is_nil(required_id)
              -> []
            to_string(id) == required_id
              -> []
            true ->
              [pharmacy_id: "Is prohibited for this user"]
          end
        {:error, _} ->
          [pharmacy_id: "Must be a positive integer"]
      end
    end)
end
def _validate_patient_id(changeset) do
  validate_change(changeset, :patient_id, fn (:patient_id, result) ->
      case result do
        {:ok, _id} ->
            []
        {:error, _} ->
          [patient_id: "Must be 'all' or a positive integer"]
      end
    end)
end
def _normalize_order_state("all"), do: {:ok, :all}
def _normalize_order_state("active"), do: {:ok, 1}
def _normalize_order_state("canceled"), do: {:ok, 2}
def _normalize_order_state("delivered"), do: {:ok, 3}
def _normalize_order_state("undeliverable"), do: {:ok, 4}
def _normalize_order_state(_), do: {:error, :invalid_order_state}

def _normalize_date(nil), do: {:ok, get_date_today()}
def _normalize_date("all"), do: {:ok, :all}
def _normalize_date("today"), do: {:ok, get_date_today() }
def _normalize_date(%{"day" => day, "month" => month, "year" => year}) do
  "#{year}-#{normalize_date_component(month)}-#{normalize_date_component(day)}"
  |> Date.from_iso8601()
end
def _normalize_date(iso8601_date_or_error) do
  Date.from_iso8601(iso8601_date_or_error)
end
def _normalize_date_component(component) do
  if String.length(component) == 1 do
    "0#{component}"
  else
    component
  end
end
def _validate_order_state(changeset) do
  msg = "Must be one of 'all', 'active', 'canceled', 'delivered', or 'undeliverable'"
  validate_change(changeset, :order_state, fn (:order_state, result) ->
      case result do
        {:ok, _} -> []
        {:error, _} -> [order_state: msg]
      end
    end)
end
def _validate_pickup_date(changeset) do
  msg = "Must either be a valid date of the form 'YYYY-MM-DD' or be one of 'all' or 'today'"
  validate_change(changeset, :pickup_date, fn (:pickup_date, result) ->
      case result do
        {:ok, _} -> []
        {:error, _} -> [pickup_date: msg]
      end
    end)
end






end
