defmodule ToCsv do
  @callback to_csv_header() :: String.t
  @delimiter "\n"
  def to_csv(implementation, []) do
    implementation.to_csv_header()
  end
  def to_csv(implementation, [_ | _] = values) do
    record = Enum.map_join(values, @delimiter, &ToCsvRecord.to_csv_record/1)
    implementation.to_csv_header() <> @delimiter <> record
  end
end

defprotocol ToCsvRecord do
  def to_csv_record(value)
end

defimpl ToCsvRecord, for: Atom do
  def to_csv_record(atom) do
    atom
    |> Atom.to_string()
    |> ToCsvRecord.to_csv_record()
  end
end

defimpl ToCsvRecord, for: BitString do
  def to_csv_record(bit_string) do
    "\"#{bit_string}\""
  end
end

defimpl ToCsvRecord, for: Date do
  def to_csv_record(%Date{} = date) do
    date
    |> to_string()
    |> ToCsvRecord.to_csv_record()
  end
end

defimpl ToCsvRecord, for: Integer do
  def to_csv_record(integer), do: to_string(integer)
end

defimpl ToCsvRecord, for: Number do
  def to_csv_record(number), do: to_string(number)
end

defimpl ToCsvRecord, for: String do
  def to_csv_record(string) do
    "\"#{string}\""
  end
end

defimpl ToCsvRecord, for: Time do
  def to_csv_record(%Time{} = time) do
    time
    |> Time.to_iso8601()
    |> String.slice(0..4)
    |> ToCsvRecord.to_csv_record()
  end
end
