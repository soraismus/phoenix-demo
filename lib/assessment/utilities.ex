defmodule Assessment.Utilities do
  alias Assessment.Utilities.ToJson

  @ok :ok
  @error :error

  @doc """
  Traverses a structure of individually validated components,
  and removes the :ok and :error validation markers,
  the result being either a collection entirely comprising valid results
  or a collection entirely comprising errors, with primacy given to the latter.

  ## Examples

      iex> accumulate_errors(%{})
      {:ok, %{}}

      iex> accumulate_errors(%{a: {:ok, 24}, b: {:ok, :y}, c: {:ok, "z"}})
      {:ok, %{a: 24, b: :y, c: "z"}}

      iex> accumulate_errors(%{a: {:ok, 24}, b: {:error, :y}, c: {:ok, "z"}})
      {:error, %{b: :b}}

      iex> accumulate_errors(%{a: {:error, 24}, b: {:error, :y}, c: {:ok, "z"}})
      {:error, %{a: 24, b: :y}}

      iex> accumulate_errors(%{a: {:error, 24}, b: {:error, :y}, c: {:error, "z"}})
      {:error, %{a: 24, b: :y, c: "z"}}

  """
  def accumulate_errors(%{} = map) do
    Enum.reduce(map, {@ok, %{}}, &reduce/2)
  end
  defp reduce({key, {@ok, value}}, {@ok, map}) do
    {@ok, Map.put(map, key, value)}
  end
  defp reduce({_, {@ok, _}}, {@error, map}) do
    {@error, map}
  end
  defp reduce({key, {@error, value}}, {@ok, _}) do
    {@error, %{key => value}}
  end
  defp reduce({key, {@error, value}}, {@error, map}) do
    {@error, Map.put(map, key, value)}
  end

  def bind_error({@ok, value}, _fun), do: {@ok, value}
  def bind_error({@error, value}, fun), do: fun.(value)

  def bind_value({@ok, value}, fun), do: fun.(value)
  def bind_value({@error, value}, _fun), do: {@error, value}

  def error_data(%{} = data) do
    fn (ok_or_error) ->
      map_error(ok_or_error, fn (value) -> Map.put(data, @error, value) end)
    end
  end

  def get_date_today() do
    :calendar.local_time()
    |> elem(0)
    |> Date.from_erl()
    |> elem(1)
    |> Date.to_iso8601()
  end

  def map_error({@ok, value}, _fun), do: {@ok, value}
  def map_error({@error, value}, fun), do: {@error, fun.(value)}

  def map_value({@ok, value}, fun), do: {@ok, fun.(value)}
  def map_value({@error, value}, _fun), do: {@error, value}

  def nilify_error({@ok, value}), do: value
  def nilify_error({@error, _}), do: nil

  def prohibit_nil(value), do: prohibit_nil(value, :invalid_nil)
  def prohibit_nil(nil, msg), do: {@error, msg}
  def prohibit_nil(value, _msg), do: {@ok, value}

  def replace_old(map, key, value) do
    try do
      Map.replace!(map, key, value)
    rescue
      KeyError -> map
    end
  end

  def to_integer(value) when is_binary(value) do
    try do
      {@ok, String.to_integer(value)}
    rescue
      ArgumentError -> {@error, :invalid_integer_format}
    end
  end

  def to_json(%_{} = struct, [_ | _] = keys) do
    struct
    |> Map.from_struct()
    |> Map.take(keys)
    |> ToJson.to_json()
  end

  defprotocol ToJson do
    def to_json(value)
  end

  defimpl ToJson, for: Atom do
    def to_json(atom), do: to_string(atom)
  end

  defimpl ToJson, for: BitString do
    def to_json(bit_string), do: to_string(bit_string)
  end

  defimpl ToJson, for: Date do
    def to_json(%Date{} = date), do: to_string(date)
  end

  defimpl ToJson, for: Integer do
    def to_json(integer), do: to_string(integer)
  end

  defimpl ToJson, for: List do
    def to_json([]), do: []
    def to_json([_ | _] = values) do
      Enum.map(values, &ToJson.to_json/1)
    end
  end

  defimpl ToJson, for: Map do
    def to_json(%{} = map) do
      Enum.reduce(map, %{}, fn ({key, value}, memo) ->
        Map.put(memo, to_string(key), ToJson.to_json(value))
      end)
    end
  end

  defimpl ToJson, for: Number do
    def to_json(number), do: to_string(number)
  end

  defimpl ToJson, for: String do
    def to_json(string), do: string
  end

  defimpl ToJson, for: Time do
    def to_json(%Time{} = time) do
      time |> Time.to_iso8601() |> String.slice(0..4)
    end
  end
end
