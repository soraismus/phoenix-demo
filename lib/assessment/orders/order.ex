defmodule Assessment.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias Assessment.Accounts.{Courier,Pharmacy}
  alias Assessment.OrderStates.OrderState
  alias Assessment.Patients.Patient

  @required_params ~w(pickup_date pickup_time patient_id pharmacy_id courier_id)a

  schema "orders" do
    field :pickup_date, :date
    field :pickup_time, :time
    belongs_to :patient, Patient
    belongs_to :pharmacy, Pharmacy
    belongs_to :courier, Courier
    belongs_to :order_state, OrderState
    field :order_state_description, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, @required_params ++ [:order_state_description])
    |> validate_required(@required_params)
    |> validate_order_state_description()
    |> set_order_state_id()
    |> unique_constraint(
        :pickup_date,
        name: :orders_pickup_date_patient_id_pharmacy_id_courier_id_index)
    |> foreign_key_constraint(:patient_id)
    |> foreign_key_constraint(:pharmacy_id)
    |> foreign_key_constraint(:courier_id)
    |> foreign_key_constraint(:order_state_id)
  end

  @order_state_descriptions ~w(active canceled delivered undeliverable)s
  defp validate_order_state_description(changeset) do
    validate_change(changeset, :order_state_description, fn (:order_state_description, description) ->
        IO.puts("description is #{description}")
        if description in @order_state_descriptions do
          []
        else
          [order_state_description: "Must be one of 'active', 'canceled', 'delivered', or 'undeliverable'"]
        end
      end)
  end

  defp set_order_state_id(changeset) do
    case get_change(changeset, :order_state_description) do
      "active" -> put_change(changeset, :order_state_id, 1)
      "canceled" -> put_change(changeset, :order_state_id, 2)
      "delivered" -> put_change(changeset, :order_state_id, 3)
      "undeliverable" -> put_change(changeset, :order_state_id, 4)
      _ -> changeset
    end
  end
end
