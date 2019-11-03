defmodule Assessment.OrderStates.OrderState do
  use Ecto.Schema
  import Ecto.Changeset
  alias Assessment.Orders.Order


  @order_states ~w(active canceled delivered undeliverable)s

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

  def order_states() do
    @order_states
  end
end
