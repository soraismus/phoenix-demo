defmodule Assessment.ToCsv do alias Assessment.Orders.Order
  alias Assessment.Accounts.{Courier, Pharmacy}
  alias Assessment.Orders.Order
  alias Assessment.OrderStates.OrderState
  alias Assessment.Patients.Patient

  import Utilities, only: [join_csv_fields: 1]

  defimpl ToCsvRecord, for: Courier do
    def to_csv_record(%Courier{} = courier) do
      [ courier.id,
        courier.name,
        courier.email,
        courier.address,
      ]
      |> join_csv_fields()
    end
  end

  defimpl ToCsvRecord, for: Order do
    def to_csv_record(%Order{} = order) do
      [ order.id,
        order.patient,
        order.pharmacy,
        order.courier,
        order.order_state,
        order.pickup_date,
        order.pickup_time,
      ]
      |> join_csv_fields()
    end
  end

  defimpl ToCsvRecord, for: OrderState do
    def to_csv_record(%OrderState{} = order_state) do
      order_state.description
      |> ToCsvRecord.to_csv_record()
    end
  end

  defimpl ToCsvRecord, for: Patient do
    def to_csv_record(%Patient{} = patient) do
      [ patient.id,
        patient.name,
        patient.address,
      ]
      |> join_csv_fields()
    end
  end

  defimpl ToCsvRecord, for: Pharmacy do
    def to_csv_record(%Pharmacy{} = pharmacy) do
      [ pharmacy.id,
        pharmacy.name,
        pharmacy.email,
        pharmacy.address,
      ]
      |> join_csv_fields()
    end
  end

  defmodule CourierToCsv do
    @behaviour ToCsv
    @delimiter ","
    @header ~w(
        courier_id
        courier_name
        courier_email
        courier_address
      )
      |> Enum.join(@delimiter)
    @impl ToCsv
    def to_csv_header(), do: @header
  end

  defmodule OrderToCsv do
    @behaviour ToCsv
    @delimiter ","
    @impl ToCsv
    def to_csv_header() do
      [ "order_id",
        Assessment.ToCsv.PatientToCsv.to_csv_header(),
        Assessment.ToCsv.PharmacyToCsv.to_csv_header(),
        Assessment.ToCsv.CourierToCsv.to_csv_header(),
        Assessment.ToCsv.OrderStateToCsv.to_csv_header(),
        "pickup_date",
        "pickup_time",
      ]
      |> Enum.join(@delimiter)
    end
  end

  defmodule OrderStateToCsv do
    @behaviour ToCsv
    @impl ToCsv
    def to_csv_header(), do: "order_state"
  end

  defmodule PatientToCsv do
    @behaviour ToCsv
    @delimiter ","
    @header ~w(
        patient_id
        patient_name
        patient_address
      )
      |> Enum.join(@delimiter)
    @impl ToCsv
    def to_csv_header(), do: @header
  end

  defmodule PharmacyToCsv do
    @behaviour ToCsv
    @delimiter ","
    @header ~w(
        pharmacy_id
        pharmacy_name
        pharmacy_email
        pharmacy_address
      )
      |> Enum.join(@delimiter)
    @impl ToCsv
    def to_csv_header(), do: @header
  end
end
