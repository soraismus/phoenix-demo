defmodule Assessment.OrderStates.OrderState do
  use Ecto.Schema
  import Ecto.Changeset
  alias Assessment.Orders.Order

  @active "active"
  @canceled "canceled"
  @delivered "delivered"
  @undeliverable "undeliverable"
  @order_states [@active, @canceled, @delivered, @undeliverable]

  schema "order_states" do
    field :description, :string
    has_many :orders, Order

    timestamps()
  end

  @doc false
  def changeset(order_state, attrs) do
    order_state
    |> cast(attrs, [:description])
    |> validate_required([:description])
    |> validate_order_state()
    |> unique_constraint(:description)
  end

  defp validate_order_state(changeset) do
    validate_change(changeset, :description, fn (:description, description) ->
        if description in @order_states do
          []
        else
          [description: "Must be one of 'active', 'canceled', 'delivered', or 'undeliverable'"]
        end
      end)
  end

  def active, do: @active
  def canceled, do: @canceled
  def delivered, do: @delivered
  def undeliverable, do: @undeliverable
  def order_states, do: @order_states
end
