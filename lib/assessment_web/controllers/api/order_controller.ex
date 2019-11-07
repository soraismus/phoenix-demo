defmodule AssessmentWeb.Api.OrderController do
  use AssessmentWeb, :controller
  import AssessmentWeb.Api.ControllerUtilities,
    only: [ authentication_error: 1,
            authorization_error: 1,
            changeset_error: 2,
            internal_error: 2,
            resource_error: 3,
            resource_error: 4
          ]
  import AssessmentWeb.GuardianController, only: [authenticate_agent: 1]
  import AssessmentWeb.OrderUtilities,
    only: [ normalize_create_params: 2,
            normalize_edit_params: 2,
            normalize_index_params: 2,
          ]
  alias Assessment.Accounts
  alias Assessment.Accounts.{Administrator,Courier,Pharmacy}
  alias Assessment.Orders

  @canceled "canceled"
  @delivered "delivered"
  @undeliverable "undeliverable"

  def cancel(conn, params) do
    conn
    |> update_order_state(params, @canceled, "cancel.json")
  end

  def create(conn, %{"order" => params}) do
    with {:ok, agent} <- authenticate_agent(conn),
         {:ok, new_params} <- authorize_creation(agent, params),
         {:ok, order} <- Orders.create_order(new_params) do
      conn
      |> put_status(:created)
      |> render("create.json", order: order)
    else
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      {:error, :not_authorized} ->
        conn
        |> authorization_error()
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("ORCR")
    end
  end

  def deliver(conn, params) do
    conn
    |> update_order_state(params, @delivered, "deliver.json")
  end

  def index(conn, _params) do
    with {:ok, _} <- authenticate_agent(conn),
         {:ok, normalized_params} <- normalize_index_params(params, account)
      conn
      |> render("index.json", orders: Orders.list_orders(normalized_params))
    else
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      _ ->
        conn
        |> internal_error("ORIN")
    end
  end

  def mark_undeliverable(conn, params) do
    conn
    |> update_order_state(params, @undeliverable, "mark_undeliverable.json")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, _} <- authenticate_agent(conn),
         {:ok, order} <- Orders.get_order(id) do
      conn
      |> render("show.json", order: order)
    else
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      {:error, :no_resource} ->
        conn
        |> resource_error("order ##{id}", "does not exist", :not_found)
      _ ->
        conn
        |> internal_error("ORSH")
    end
  end

  defp authorize_creation(agent, params) do
    case Accounts.specify_agent(agent) do
      %Administrator{} ->
        {:ok, params}
      (%Courier{} = courier) ->
        key = "courier_id"
        if !Map.has_key?(params, key) || params[key] == courier.id do
          {:ok, Map.put(params, key, courier.id)}
        else
          {:error, :not_authorized}
        end
      (%Pharmacy{} = pharmacy) ->
        key = "pharmacy_id"
        if !Map.has_key?(params, key) || params[key] == pharmacy.id do
          {:ok, Map.put(params, key, pharmacy.id)}
        else
          {:error, :not_authorized}
        end
    end
  end

  defp authorize_update(agent, order) do
    case agent.account_type do
      "administrator" ->
        {:ok, agent.administrator}
      "courier" ->
        if order.courier_id == agent.courier.id do
          {:ok, agent.courier}
        else
          {:error, :not_authorized}
        end
      "pharmacy" ->
        if order.pharmacy_id == agent.pharmacy.id do
          {:ok, agent.pharmacy}
        else
          {:error, :not_authorized}
        end
      _ ->
        {:error, :not_authorized}
    end
  end

  defp check_elibility(order, order_state_description) do
    cond do
      order.order_state_description == order_state_description ->
        {:error, :already_has_order_state}
      order.order_state_description == @canceled ->
        {:error, :already_canceled}
      order.order_state_description == @delivered ->
        {:error, :already_delivered}
      true ->
        {:ok, {order, order_state_description}}
    end
  end

  defp update_order_state(conn, %{"id" => id}, description, view) do
    resource = "order ##{id}"
    with {:ok, agent} <- authenticate_agent(conn),
         {:ok, order} <- Orders.get_order(id),
         {:ok, _} <- authorize_update(agent, order),
         {:ok, _} <- check_elibility(order, description),
         {:ok, new_order} <- Orders.update_order_state(order, description) do
      conn
      |> render(view, order: new_order)
    else
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      {:error, :not_authorized} ->
        conn
        |> authorization_error()
      {:error, :already_canceled} ->
        msg = "cannot be #{description} because it has already been canceled"
        conn
        |> resource_error(resource, msg)
      {:error, :already_delivered} ->
        msg = "cannot be #{description} because it has already been delivered"
        conn
        |> resource_error(resource, msg)
      {:error, :already_has_order_state} ->
        conn
        |> resource_error(resource, "is already #{description}")
      {:error, :no_resource} ->
        conn
        |> resource_error(resource, "does not exist", :not_found)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("ORUP")
    end
  end
end
