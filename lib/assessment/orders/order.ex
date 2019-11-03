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

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:patient_id)
    |> foreign_key_constraint(:pharmacy_id)
    |> foreign_key_constraint(:courier_id)
    |> foreign_key_constraint(:order_state_id)
  end
end
