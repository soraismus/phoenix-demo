defmodule Assessment.OrderStates do
  @moduledoc """
  The OrderStates context.
  """

  import Ecto.Query, warn: false
  import Utilities, only: [prohibit_nil: 2]

  alias Assessment.Repo
  alias Assessment.OrderStates.OrderState

  @active OrderState.active()
  @active_id 1
  @canceled OrderState.canceled()
  @canceled_id 2
  @delivered OrderState.delivered()
  @delivered_id 3
  @no_resource :no_resource
  @undeliverable OrderState.undeliverable()
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

  ## Examples

      iex> get_order_state(123)
      {:ok, %OrderState{}}

      iex> get_order_state(456)
      {:error, :no_resource}

  """
  def get_order_state(id) do
    OrderState
    |> Repo.get(id)
    |> prohibit_nil(@no_resource)
  end

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
  def to_description(@active_id), do: @active
  def to_description(@canceled_id), do: @canceled
  def to_description(@delivered_id), do: @delivered
  def to_description(@undeliverable_id), do: @undeliverable

  @doc false
  def undeliverable_id(), do: @undeliverable_id
end
