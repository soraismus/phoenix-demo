defmodule ToCsv do
  @callback to_csv_field_prefix() :: String.t
  @callback to_csv_fields() :: [String.t]

  @field_delimiter ","
  @name_delimiter "_"
  @record_delimiter "\n"

  def to_csv(implementation, list, should_prefix? \\ true)
  def to_csv(implementation, [], should_prefix?) do
    to_csv_header(implementation, should_prefix?)
  end
  def to_csv(implementation, [_ | _] = values, should_prefix?) do
    record = Enum.map_join(values, @record_delimiter, &ToCsvRecord.to_csv_record/1)
    to_csv_header(implementation, should_prefix?) <> @record_delimiter <> record
  end

  def join_csv_fields(values) when is_list(values) do
    values
    |> Enum.map_join(",", &ToCsvRecord.to_csv_record/1)
  end
  def join_csv_fields(%{} = struct) do
    HasCsvFields.to_csv_implementation(struct).to_csv_fields()
    |> Enum.map(&String.to_existing_atom/1)
    |> Enum.map(fn (field) -> Map.get(struct, field) end)
    |> join_csv_fields()
  end

  def separate_composite_fields(fields_and_headers) when is_list(fields_and_headers) do
    fields_and_headers
    |> Enum.join(",")
    |> String.split(",")
  end

  def to_csv_header(implementation, should_prefix? \\ true)
  def to_csv_header(implementation, should_prefix?) do
    prefix =
      if should_prefix? do
        implementation.to_csv_field_prefix() <> @name_delimiter
      else
        ""
      end
    implementation.to_csv_fields()
    |> Enum.map_join(@field_delimiter, fn (field) ->
          prefix <> to_string(field)
        end)
  end
end

defprotocol HasCsvFields do
  def to_csv_implementation(value)
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
