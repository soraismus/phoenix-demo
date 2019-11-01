defmodule Assessment.OrderStates.OrderState do
  use Ecto.Schema
  import Ecto.Changeset


  schema "order_states" do
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(order_state, attrs) do
    order_state
    |> cast(attrs, [:description])
    |> validate_required([:description])
    |> unique_constraint(:description)
  end
end
