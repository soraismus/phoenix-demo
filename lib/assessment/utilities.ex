defmodule Assessment.Utilities do
  @type ok_or_error(a, b) :: {:ok, a} | {:error, b}
  @type value_or_nil(a) :: a | nil

  @ok :ok
  @error :error

  @spec bind_error(ok_or_error(a, b), (b -> ok_or_error(a, c))) :: ok_or_error(a, c)
        when a: var, b: var, c: var
  def bind_error({@ok, value}, _fun), do: {@ok, value}
  def bind_error({@error, value}, fun), do: fun.(value)

  @spec bind_value(ok_or_error(a, b), (a -> ok_or_error(c, b))) :: ok_or_error(c, b)
        when a: var, b: var, c: var
  def bind_value({@ok, value}, fun), do: fun.(value)
  def bind_value({@error, value}, _fun), do: {@error, value}

  @spec error_data(map()) :: (ok_or_error(a, b) -> ok_or_error(a, %{error: b}))
        when a: var, b: var, c: var
  def error_data(%{} = data) do
    fn (ok_or_error) ->
      map_error(ok_or_error, fn (value) -> Map.put(data, :error, value) end)
    end
  end

  @spec get_date_today() :: binary()
  def get_date_today() do
    :calendar.local_time()
    |> elem(0)
    |> Date.from_erl()
    |> elem(1)
    |> Date.to_iso8601()
  end

  @spec map_error(ok_or_error(a, b), (b -> c)) :: ok_or_error(a, c)
        when a: var, b: var, c: var
  def map_error({@ok, value}, _fun), do: {@ok, value}
  def map_error({@error, value}, fun), do: {@error, fun.(value)}

  @spec map_value(ok_or_error(a, b), (a -> c)) :: ok_or_error(c, b)
        when a: var, b: var, c: var
  def map_value({@ok, value}, fun), do: {@ok, fun.(value)}
  def map_value({@error, value}, _fun), do: {@error, value}

  @spec nilify_error(ok_or_error(a, any())) :: a | nil when a: var
  def nilify_error({:ok, value}), do: value
  def nilify_error({:error, _}), do: nil

  @spec prohibit_nil(value_or_nil(a)) :: ok_or_error(a, :invalid_nil) when a: var
  @spec prohibit_nil(value_or_nil(a), b) :: ok_or_error(a, b) when a: var, b: var
  def prohibit_nil(value), do: prohibit_nil(value, :invalid_nil)
  def prohibit_nil(nil, msg), do: {@error, msg}
  def prohibit_nil(value, _msg), do: {@ok, value}

  @spec to_integer(binary()) :: ok_or_error(integer(), :invalid_integer_format)
  def to_integer(value) when is_binary(value) do
    try do
      {:ok, String.to_integer(value)}
    rescue
      ArgumentError -> {:error, :invalid_integer_format}
    end
  end
end
