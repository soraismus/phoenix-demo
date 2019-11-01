defmodule Assessment.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset


  schema "orders" do
    field :pickup_date, :date
    field :pickup_time, :time
    field :patient_id, :id
    field :pharmacy_id, :id
    field :courier_id, :id
    field :order_state_id, :id

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:pickup_date, :pickup_time])
    |> validate_required([:pickup_date, :pickup_time])
  end
end
