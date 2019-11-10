defmodule Assessment.OrderStates do
  @moduledoc """
  The OrderStates context.
  """

  import Ecto.Query, warn: false

  alias Assessment.Repo
  alias Assessment.OrderStates.OrderState

  @active_id 1
  @canceled_id 2
  @delivered_id 3
  @undeliverable_id 4

  @doc """
  Returns the list of order_states.

  ## Examples

      iex> list_order_states()
      [%OrderState{}, ...]

  """
  def list_order_states do
    Repo.all(OrderState)
  end

  @doc """
  Gets a single order_state.

  Raises `Ecto.NoResultsError` if the Order state does not exist.

  ## Examples

      iex> get_order_state!(123)
      %OrderState{}

      iex> get_order_state!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order_state!(id), do: Repo.get!(OrderState, id)

  @doc """
  Creates a order_state.

  ## Examples

      iex> create_order_state(%{field: value})
      {:ok, %OrderState{}}

      iex> create_order_state(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order_state(attrs \\ %{}) do
    %OrderState{}
    |> OrderState.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order_state.

  ## Examples

      iex> update_order_state(order_state, %{field: new_value})
      {:ok, %OrderState{}}

      iex> update_order_state(order_state, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order_state(%OrderState{} = order_state, attrs) do
    order_state
    |> OrderState.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a OrderState.

  ## Examples

      iex> delete_order_state(order_state)
      {:ok, %OrderState{}}

      iex> delete_order_state(order_state)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order_state(%OrderState{} = order_state) do
    Repo.delete(order_state)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order_state changes.

  ## Examples

      iex> change_order_state(order_state)
      %Ecto.Changeset{source: %OrderState{}}

  """
  def change_order_state(%OrderState{} = order_state) do
    OrderState.changeset(order_state, %{})
  end

  @doc false
  def active_id(), do: @active_id

  @doc false
  def canceled_id(), do: @canceled_id

  @doc false
  def delivered_id(), do: @delivered_id

  @doc false
  def to_description(@active_id), do: OrderState.active()
  def to_description(@canceled_id), do: OrderState.canceled()
  def to_description(@delivered_id), do: OrderState.delivered()
  def to_description(@undeliverable_id), do: OrderState.undeliverable()

  @doc false
  def undeliverable_id(), do: @undeliverable_id
end
