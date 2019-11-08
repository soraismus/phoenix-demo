defmodule AssessmentWeb.Api.OrderController do
  use AssessmentWeb, :controller
  import Assessment.Utilities, only: [accumulate_errors: 1]
  import AssessmentWeb.Api.ControllerUtilities,
    only: [ authentication_error: 1,
            authorization_error: 1,
            changeset_error: 2,
            internal_error: 2,
            resource_error: 3,
            resource_error: 4,
            validation_error: 2,
          ]
  import AssessmentWeb.GuardianController, only: [authenticate_agent: 1]
  import AssessmentWeb.OrderUtilities,
    only: [ normalize_create_params: 2,
            normalize_edit_params: 2,
            normalize_index_params: 2,
            normalize_validate_creation: 2,
            normalize_validate_index: 2,
            _normalize_and_validate: 2,
          ]
  alias Assessment.Accounts
  alias Assessment.Accounts.{Administrator,Courier,Pharmacy}
  alias Assessment.Orders
  alias Assessment.Utilities.ToJson
  alias AssessmentWeb.Api.OrderView

  @canceled "canceled"
  @delivered "delivered"
  @undeliverable "undeliverable"
  @order_state_error_msg "Must be one of 'all', 'active', 'canceled', 'delivered', or 'undeliverable'"

  def cancel(conn, params) do
    conn
    |> update_order_state(params, @canceled, "cancel.json")
  end

  def create(conn, %{"order" => params}) do
    with {:ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         validated_params <- normalize_validate_creation(params, account),
         {:ok, normalized_params} <- accumulate_errors(validated_params),
         {:ok, order} <- Orders.create_order(normalized_params) do
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
      {:error, %{} = errors} ->
        conn
        |> validation_error(OrderView.format_creation_errors(errors))
      x ->
        IO.inspect("ORCR")
        IO.inspect(x)
        conn
        |> internal_error("ORCR")
    end
  end

  def deliver(conn, params) do
    conn
    |> update_order_state(params, @delivered, "deliver.json")
  end

  def index(conn, params) do
    with {:ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         validated_params <- normalize_validate_index(params, account),
         {:ok, normalized_params} <- accumulate_errors(validated_params) do
      conn
      |> render(
            "index.json",
            orders: Orders.list_orders(normalized_params),
            query_params: normalized_params)
    else
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      {:error, :not_authorized} ->
        conn
        |> authorization_error()
      {:error, %{} = errors} ->
        conn
        |> validation_error(OrderView.format_index_errors(errors))
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
