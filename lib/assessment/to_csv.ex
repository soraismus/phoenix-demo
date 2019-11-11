defmodule Assessment.ToCsv do alias Assessment.Orders.Order
  alias Assessment.Accounts.{Courier, Pharmacy}
  alias Assessment.Orders.Order
  alias Assessment.OrderStates.OrderState
  alias Assessment.Patients.Patient

  import ToCsv, only: [join_csv_fields: 1, prefix: 2]

  defmodule CourierToCsv do
    @behaviour ToCsv
    @impl ToCsv
    def to_csv_field_prefix(), do: "courier"
    @impl ToCsv
    def to_csv_fields(), do: ~w(id name email address)s
  end

  defmodule OrderToCsv do
    @behaviour ToCsv
    @prefix "order"
    @impl ToCsv
    def to_csv_field_prefix(), do: @prefix
    @impl ToCsv
    def to_csv_fields() do
      [ "id",
        ToCsv.to_csv_header(Assessment.ToCsv.PatientToCsv),
        ToCsv.to_csv_header(Assessment.ToCsv.PharmacyToCsv),
        ToCsv.to_csv_header(Assessment.ToCsv.CourierToCsv),
        ToCsv.to_csv_header(Assessment.ToCsv.OrderStateToCsv),
        "pickup_date",
        "pickup_time",
      ]
      |> Enum.join(",")
      |> String.split(",")
    end
    defp prefix(value) do
      prefix(value, @prefix)
    end
  end

  defmodule OrderStateToCsv do
    @behaviour ToCsv
    @impl ToCsv
    def to_csv_field_prefix(), do: "state"
    @impl ToCsv
    def to_csv_fields(), do: ["description"]
  end

  defmodule PatientToCsv do
    @behaviour ToCsv
    @impl ToCsv
    def to_csv_field_prefix(), do: "patient"
    @impl ToCsv
    def to_csv_fields(), do: ~w(id name address)s
  end

  defmodule PharmacyToCsv do
    @behaviour ToCsv
    @impl ToCsv
    def to_csv_field_prefix(), do: "pharmacy"
    @impl ToCsv
    def to_csv_fields(), do: ~w(id name email address)s
  end

  defimpl ToCsvRecord, for: Courier do
    def to_csv_record(%Courier{} = courier) do
      join_csv_fields(courier)
    end
  end
  defimpl HasCsvFields, for: Courier do
    def to_csv_implementation(%Courier{}) do
      Assessment.ToCsv.CourierToCsv
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
  defimpl HasCsvFields, for: Order do
    def to_csv_implementation(%Order{}) do
      Assessment.ToCsv.OrderToCsv
    end
  end

  defimpl ToCsvRecord, for: OrderState do
    def to_csv_record(%OrderState{} = order_state) do
      join_csv_fields(order_state)
    end
  end
  defimpl HasCsvFields, for: OrderState do
    def to_csv_implementation(%OrderState{}) do
      Assessment.ToCsv.OrderStateToCsv
    end
  end

  defimpl ToCsvRecord, for: Patient do
    def to_csv_record(%Patient{} = patient) do
      join_csv_fields(patient)
    end
  end
  defimpl HasCsvFields, for: Patient do
    def to_csv_implementation(%Patient{}) do
      Assessment.ToCsv.PatientToCsv
    end
  end

  defimpl ToCsvRecord, for: Pharmacy do
    def to_csv_record(%Pharmacy{} = pharmacy) do
      join_csv_fields(pharmacy)
    end
  end
  defimpl HasCsvFields, for: Pharmacy do
    def to_csv_implementation(%Pharmacy{}) do
      Assessment.ToCsv.PharmacyToCsv
    end
  end
end
