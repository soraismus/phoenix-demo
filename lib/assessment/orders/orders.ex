defmodule Assessment.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias Assessment.{Repo,Utilities}
  alias Assessment.Orders.Order
  alias Assessment.OrderStates.OrderState
  alias Ecto.Changeset


  @no_resource :no_resource
  @active_order_state_id 1

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders(%{})
      [%Order{}, ...]

      iex> list_orders(%{pickup_date: :all})
      [%Order{}, ...]

      iex> list_orders(%{pickup_date: %Date{year: _, month: _, day: _}})
      [%Order{}, ...]

      iex> list_orders(%{order_state_id: :all})
      [%Order{}, ...]

      iex> list_orders(%{order_state_id: 1})
      [%Order{}, ...]

      iex> list_orders(%{patient_id: :all})
      [%Order{}, ...]

      iex> list_orders(%{patient_id: 1})
      [%Order{}, ...]

      iex> list_orders(%{courier_id: 1, pharmacy_id: 1})
      [%Order{}, ...]

      iex> list_orders(%{courier_id: 1, pickup_date: :all, pharmacy_id: 1})
      [%Order{}, ...]

  """
  def list_orders(params), do: Repo.all(create_query(params))
  defp create_query(params) do
    query =
      from o in Order,
      inner_join: c in assoc(o, :courier),
      inner_join: os in assoc(o, :order_state),
      inner_join: p in assoc(o, :patient),
      inner_join: ph in assoc(o, :pharmacy),
      preload: [courier: c, order_state: os, patient: p, pharmacy: ph]
    query = if Map.has_key?(params, :courier_id) do
              query |> where([o], o.courier_id == ^params.courier_id)
            else
              query
            end
    query = if Map.has_key?(params, :order_state_id) && params.order_state_id != :all do
              query |> where([o], o.order_state_id == ^params.order_state_id)
            else
              query
            end
    query = if Map.has_key?(params, :patient_id) && params.patient_id != :all do
              query |> where([o], o.patient_id == ^params.patient_id)
            else
              query
            end
    query = if Map.has_key?(params, :pharmacy_id) do
              query |> where([o], o.pharmacy_id == ^params.pharmacy_id)
            else
              query
            end
    query = if Map.has_key?(params, :pickup_date) && params.pickup_date != :all do
              query |> where([o], o.pickup_date == ^params.pickup_date)
            else
              query
            end
    query
  end

  @doc """
  Gets a single order.

  ## Examples

      iex> get_order(123)
      {:ok, %Order{}}

      iex> get_order(456)
      {:error, :no_resource}

  """
  def get_order(id) do
    Order
    |> Repo.get(id)
    |> Repo.preload([:patient, :pharmacy, :courier, :order_state])
    |> Utilities.prohibit_nil(@no_resource)
    |> Utilities.map_value(&set_order_state_description/1)
  end

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Changeset.put_change(:order_state_id, @active_order_state_id)
    |> Repo.insert()
    |> Utilities.map_value(fn (order) ->
          Repo.preload(order, [:patient, :pharmacy, :courier, :order_state])
        end)
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{source: %Order{}}

  """
  def change_order(%Order{} = order) do
    Order.changeset(order, %{})
  end

  defp set_order_state_description(%{order_state: %OrderState{} = order_state} = order) do
    %{order | order_state_description: order_state.description}
  end
end
